package main

import (
	"flag"
	"os"

	"github.com/zzl/go-win32api/win32"
)

var (
	operation = flag.String("op", "open", "operation name (default: open)")
	filepath  = flag.String("file", "", "path and name of file")
	params    = flag.String("params", "", "parameters")
	directory = flag.String("directory", "", "working directory")
	minimize  = flag.Bool("minimize", false, "minimize the process")
)

func main() {
	flag.Parse()
	show := int32(win32.SW_SHOWDEFAULT)
	if *minimize {
		show = int32(win32.SW_SHOWMINNOACTIVE)
	}
	_ = win32.ShellExecute(
		0,
		win32.StrToPwstr(*operation),
		win32.StrToPwstr(*filepath),
		win32.StrToPwstr(*params),
		win32.StrToPwstr(*directory),
		show,
	)
	lastErr := win32.GetLastError()
	if lastErr.NilOrError() != nil {
		_, _ = win32.MessageBoxEx(
			0,
			win32.StrToPwstr(lastErr.Error()),
			win32.StrToPwstr("ShellExecute Error"),
			win32.MB_OK,
			0,
		)
		os.Exit(1)
	}
}
