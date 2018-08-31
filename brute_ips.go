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
	"sort"
	"strconv"
	"sync"
)

func main() {
	hashes := readHashes("/tmp/ip-hashes")

	w, hashes, closeCache := prepareCache("/tmp/ip-hashes-cache", hashes)
	defer closeCache()
	if len(hashes) == 0 {
		return
	}

	sort.Slice(hashes, func(i, j int) bool {
		return bytes.Compare(hashes[i][:], hashes[j][:]) < 0
	})

	need := func(hash [sha1.Size]byte) bool {
		// inlined sort.Search

		// Define f(-1) == false and f(n) == true.
		// Invariant: f(i-1) == false, f(j) == true.
		i, j := 0, len(hashes)
		for i < j {
			h := int(uint(i+j) >> 1) // avoid overflow when computing h
			// i ≤ h < j
			switch cmp := bytes.Compare(hashes[h][:], hash[:]); {
			case cmp == 0:
				return true
			case cmp < 0:
				i = h + 1 // preserves f(i-1) == false
			default:
				j = h // preserves f(j) == true
			}
		}
		// i == j, f(i-1) == false, and f(j) (= f(i)) == true  =>  answer is i.
		return i < len(hashes) && hashes[i] == hash
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

func readHashes(name string) (hashes [][sha1.Size]byte) {
	f, err := os.Open(name)
	if err != nil {
		panic(err)
	}
	defer func() {
		if err := f.Close(); err != nil {
			panic(err)
		}
	}()

	s := bufio.NewScanner(f)
	for s.Scan() {
		var hash [sha1.Size]byte
		if n, err := hex.Decode(hash[:], s.Bytes()); err != nil {
			panic(err)
		} else if n != sha1.Size {
			panic("short read")
		}
		hashes = append(hashes, hash)
	}

	if err := s.Err(); err != nil {
		panic(err)
	}

	return
}

func brute(wg *sync.WaitGroup, found chan<- [4 + sha1.Size]byte, need func([sha1.Size]byte) bool, offset, stride uint64) {
	defer wg.Done()

	for ip := offset; ip < 1<<32; ip += stride {
		tryHash(found, need, ip)
	}
}

func tryHash(found chan<- [4 + sha1.Size]byte, need func([sha1.Size]byte) bool, ip uint64) {
	payload := make([]byte, 0, sha1.Size*2+len(secret))
	payload = strconv.AppendUint(payload, (ip>>24)&0xff, 10)
	payload = append(payload, '.')
	payload = strconv.AppendUint(payload, (ip>>16)&0xff, 10)
	payload = append(payload, '.')
	payload = strconv.AppendUint(payload, (ip>>8)&0xff, 10)
	payload = append(payload, '.')
	payload = strconv.AppendUint(payload, ip&0xff, 10)
	payload = append(payload, secret...)

	checkHash := func(hash [sha1.Size]byte) {
		if need(hash) {
			var foundPayload [4 + sha1.Size]byte
			binary.BigEndian.PutUint32(foundPayload[:4], uint32(ip))
			copy(foundPayload[4:], hash[:])
			found <- foundPayload
		}
	}

	hash := sha1.Sum(payload)
	checkHash(hash)

	payload = payload[:sha1.Size*2]
	hex.Encode(payload, hash[:])
	payload = append(payload, secret...)
	hash = sha1.Sum(payload)
	checkHash(hash)

	payload = append(payload[:0], "::ffff:"...)
	payload = strconv.AppendUint(payload, (ip>>24)&0xff, 10)
	payload = append(payload, '.')
	payload = strconv.AppendUint(payload, (ip>>16)&0xff, 10)
	payload = append(payload, '.')
	payload = strconv.AppendUint(payload, (ip>>8)&0xff, 10)
	payload = append(payload, '.')
	payload = strconv.AppendUint(payload, ip&0xff, 10)
	payload = append(payload, secret...)
	hash = sha1.Sum(payload)
	checkHash(hash)

	payload = payload[:sha1.Size*2]
	hex.Encode(payload, hash[:])
	payload = append(payload, secret...)
	hash = sha1.Sum(payload)
	checkHash(hash)
}

func prepareCache(name string, hashes [][sha1.Size]byte) (io.Writer, [][sha1.Size]byte, func()) {
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

	notFound := make(map[[sha1.Size]byte]struct{}, len(hashes))
	for _, h := range hashes {
		notFound[h] = struct{}{}
	}

	found := make(chan [4 + sha1.Size]byte, 100)
	var wg sync.WaitGroup
	wg.Add(1)
	go func() {
		wg.Wait()
		close(found)
	}()

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

		var hash [sha1.Size]byte
		hashText := line[tabIndex+1 : len(line)-1]
		_, err = hex.Decode(hash[:], hashText)
		if err != nil {
			continue
		}

		index := sort.Search(len(hashes), func(i int) bool {
			return bytes.Compare(hashes[i][:], hash[:]) >= 0
		})
		if index >= len(hashes) || hashes[index] != hash {
			continue
		}

		wg.Add(1)
		go func() {
			tryHash(found, func(b [sha1.Size]byte) bool {
				return true
			}, uint64(ip[0])<<24|uint64(ip[1])<<16|uint64(ip[2])<<8|uint64(ip[3]))

			wg.Done()
		}()
	}
	wg.Done()

	for ip := range found {
		var hash [sha1.Size]byte
		copy(hash[:], ip[4:])

		if _, ok := notFound[hash]; ok {
			fmt.Fprintf(w, "%d.%d.%d.%d\t%x\n", ip[0], ip[1], ip[2], ip[3], hash)
			delete(notFound, hash)
		}
	}

	hashes = make([][sha1.Size]byte, 0, len(notFound))
	for h := range notFound {
		hashes = append(hashes, h)
	}

	return w, hashes, func() {
		if err := f.Close(); err != nil {
			panic(err)
		}
	}
}
