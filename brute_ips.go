package main

import (
	"bufio"
	"bytes"
	"crypto/sha1"
	"encoding/binary"
	"encoding/hex"
	"fmt"
	"io"
	"io/ioutil"
	"net"
	"os"
	"runtime"
	"sync"
)

func main() {
	hashes := readHashes("/tmp/ip-hashes")

	w, closeCache := prepareCache("/tmp/ip-hashes-cache", hashes)
	defer closeCache()
	if len(hashes) == 0 {
		return
	}

	need := func(hash [sha1.Size]byte) bool {
		_, ok := hashes[hash]
		return ok
	}

	workers := runtime.GOMAXPROCS(0)
	var wg sync.WaitGroup
	wg.Add(workers)
	found := make(chan [4 + sha1.Size]byte, 100)
	go func() {
		wg.Wait()
		close(found)
	}()

	for i := 0; i < workers; i++ {
		go brute(&wg, found, need, uint64(i), uint64(workers))
	}

	for f := range found {
		ip := f[:4]
		hash := f[4:]
		fmt.Fprintf(w, "%d.%d.%d.%d\t%x\n", ip[0], ip[1], ip[2], ip[3], hash)
	}
}

func readHashes(name string) map[[sha1.Size]byte]struct{} {
	f, err := os.Open(name)
	if err != nil {
		panic(err)
	}
	defer func() {
		if err := f.Close(); err != nil {
			panic(err)
		}
	}()

	hashes := make(map[[sha1.Size]byte]struct{})

	s := bufio.NewScanner(f)
	for s.Scan() {
		var hash [sha1.Size]byte
		if n, err := hex.Decode(hash[:], s.Bytes()); err != nil {
			panic(err)
		} else if n != sha1.Size {
			panic("short read")
		}
		hashes[hash] = struct{}{}
	}

	if err := s.Err(); err != nil {
		panic(err)
	}

	return hashes
}

func brute(wg *sync.WaitGroup, found chan<- [4 + sha1.Size]byte, need func([sha1.Size]byte) bool, offset, stride uint64) {
	defer wg.Done()

	var ipBytes [4]uint8

	for ip := offset; ip < 1<<32; ip += stride {
		binary.BigEndian.PutUint32(ipBytes[:], uint32(ip))
		sendHash(found, need, net.IP(ipBytes[:]).String(), ipBytes)
	}
}

func sendHash(found chan<- [4 + sha1.Size]byte, need func([sha1.Size]byte) bool, ip string, ipBytes [4]byte) {
	send := func(hash [sha1.Size]byte) {
		if need(hash) {
			var foundPayload [4 + sha1.Size]byte
			copy(foundPayload[:4], ipBytes[:])
			copy(foundPayload[4:], hash[:])
			found <- foundPayload
		}
	}

	tryHash(ip, 2, send)
	tryHash("::ffff:"+ip, 2, send)
}

func tryHash(payload string, depth int, send func([sha1.Size]byte)) {
	for i := 0; i < depth; i++ {
		hash := sha1.Sum([]byte(payload + secret))
		send(hash)
		payload = hex.EncodeToString(hash[:])
	}
}

// Invalid IP addresses from the WTDWTF dataset.
var rubbish = [...]string{
	"",
	"999.999.999.999",
	"unknown",
}

func prepareCache(name string, hashes map[[sha1.Size]byte]struct{}) (io.Writer, func()) {
	b, err := ioutil.ReadFile(name)
	if os.IsNotExist(err) {
		b, err = nil, nil
	}
	if err != nil {
		panic(err)
	}

	f, err := os.Create(name)
	if err != nil {
		panic(err)
	}

	w := io.MultiWriter(f, os.Stdout)

	type result struct {
		payload string
		hash    [sha1.Size]byte
		isIP    bool
		cache   bool
	}

	found := make(chan result, 100)
	var wg sync.WaitGroup

	bad := func(payloads []string, depth int, isIP bool) {
		wg.Add(len(payloads))
		for _, s := range payloads {
			payload := s
			go func() {
				tryHash(payload, depth, func(hash [sha1.Size]byte) {
					found <- result{
						payload: payload,
						hash:    hash,
						isIP:    isIP,
						cache:   false,
					}
				})

				wg.Done()
			}()
		}
	}

	bad(rubbish[:], 2, false)

	lines := bytes.SplitAfter(b, []byte{'\n'})
	for _, line := range lines {
		if len(line) < 9+2*sha1.Size {
			// Can't possibly be an IPv4, a tab, a hex SHA1, and a newline.
			continue
		}

		tabIndex := len(line) - 1 - 2*sha1.Size - 1
		if line[tabIndex] != '\t' || line[len(line)-1] != '\n' {
			continue
		}

		ipText := line[:tabIndex]
		ip := net.ParseIP(string(ipText)).To4()
		if len(ip) != 4 {
			continue
		}
		var ipBytes [4]byte
		copy(ipBytes[:], ip)

		var hash [sha1.Size]byte
		hashText := line[tabIndex+1 : len(line)-1]
		_, err = hex.Decode(hash[:], hashText)
		if err != nil {
			continue
		}

		wg.Add(1)
		payload := ip.String()
		go func() {
			foundIP := func(hash [sha1.Size]byte) {
				found <- result{
					payload: payload,
					hash:    hash,
					isIP:    true,
					cache:   true,
				}
			}
			tryHash(payload, 2, foundIP)
			tryHash("::ffff:"+payload, 2, foundIP)

			wg.Done()
		}()
	}

	go func() {
		wg.Wait()
		close(found)
	}()

	for r := range found {
		if _, ok := hashes[r.hash]; ok {
			if r.isIP {
				out := w
				if !r.cache {
					out = os.Stdout
				}
				fmt.Fprintf(out, "%s\t%x\n", r.payload, r.hash)
			}
			delete(hashes, r.hash)
		}
	}

	return w, func() {
		if err := f.Close(); err != nil {
			panic(err)
		}
	}
}
