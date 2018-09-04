// +build ignore

package main

import (
	"fmt"
	"path/filepath"
	"sort"
	"strconv"
	"strings"
)

type Tree struct {
	Prefix string
	IsFile bool
	Sub    map[string]*Tree
	Seq    []*Tree
}

func (t *Tree) Add(name string) {
	if !strings.HasPrefix(name, t.Prefix) {
		panic("internal error: missing prefix:\n" + t.Prefix + "\n" + name)
	}

	suffix := name[len(t.Prefix):]
	if suffix == "" {
		t.IsFile = true
		return
	}

	if len(suffix) > 4 &&
		suffix[0] >= '0' && suffix[0] <= '9' &&
		suffix[1] >= '0' && suffix[1] <= '9' &&
		suffix[2] >= '0' && suffix[2] <= '9' &&
		suffix[3] >= '0' && suffix[3] <= '9' &&
		suffix[4] == '.' {
		num, err := strconv.Atoi(suffix[:4])
		if err != nil {
			panic(err)
		}

		if len(t.Seq) <= num {
			t.Seq = append(t.Seq, make([]*Tree, num-len(t.Seq)+1)...)
		}
		if t.Seq[num] == nil {
			t.Seq[num] = &Tree{
				Prefix: t.Prefix + suffix[:5],
			}
		}
		t.Seq[num].Add(name)
		return
	}

	if t.Sub == nil {
		t.Sub = make(map[string]*Tree)
	}

	part := suffix[:strings.IndexByte(suffix, '.')]

	if _, ok := t.Sub[part]; !ok {
		t.Sub[part] = &Tree{
			Prefix: t.Prefix + part + ".",
		}
	}

	t.Sub[part].Add(name)
}

func (t *Tree) Print(pre ...string) {
	fmt.Printf(".PHONY: %sall\n", t.Prefix)
	fmt.Printf("%sall:", t.Prefix)
	if t.Sub != nil {
		fmt.Printf(" %ssub", t.Prefix)
	}
	if t.Seq != nil {
		fmt.Printf(" %sseq", t.Prefix)
	}
	if t.IsFile {
		fmt.Printf(" %sdo", t.Prefix)
	}
	fmt.Println()

	if t.IsFile && len(pre) != 0 {
		fmt.Printf("%sdo:", t.Prefix)
		for _, p := range pre {
			fmt.Printf(" %s", p)
		}
		fmt.Println()
	}

	if t.Sub != nil {
		t.PrintSub(pre...)
	}
	if t.Seq != nil {
		t.PrintSeq(pre...)
	}
}

func (t *Tree) PrintSub(pre ...string) {
	keys := make([]string, 0, len(t.Sub))
	for k := range t.Sub {
		keys = append(keys, k)
	}
	sort.Strings(keys)

	fmt.Printf(".PHONY: %ssub\n", t.Prefix)
	fmt.Printf("%ssub:", t.Prefix)
	for _, k := range keys {
		fmt.Printf(" %s%s.all", t.Prefix, k)
	}
	fmt.Println()
	for _, k := range keys {
		t.Sub[k].Print(pre...)
	}
}

func (t *Tree) PrintSeq(pre ...string) {
	indexes := make([]int, 0, len(t.Seq))
	for i, s := range t.Seq {
		if s != nil {
			indexes = append(indexes, i)
		}
	}

	fmt.Printf(".PHONY: %sseq\n", t.Prefix)
	fmt.Printf("%sseq: %s%04d.all\n", t.Prefix, t.Prefix, indexes[len(indexes)-1])
	for i := len(indexes) - 1; i > 0; i-- {
		t.Seq[indexes[i]].Print(append(pre, fmt.Sprintf("%s%04d.all", t.Prefix, indexes[i-1]))...)
	}
	t.Seq[indexes[0]].Print(pre...)
}

func main() {
	files, err := filepath.Glob("*.sql")
	if err != nil {
		panic(err)
	}

	var tree Tree

	for _, name := range files {
		tree.Add(strings.TrimSuffix(name, "sql"))
	}

	tree.Print()
}
