class GoAT19 < Formula
  desc "Go programming environment (1.9)"
  homepage "https://golang.org"
  url "https://dl.google.com/go/go1.9.7.src.tar.gz"
  mirror "https://fossies.org/linux/misc/go1.9.7.src.tar.gz"
  sha256 "582814fa45e8ecb0859a208e517b48aa0ad951e3b36c7fff203d834e0ef27722"

  bottle do
    sha256 "097a7bde112c08b746f167b1f10603cf714369fb90da1c4fe3ead6980ca319fb" => :high_sierra
    sha256 "85b2bb9a42d7b414c31a98ab0fbdfcb3aa540ee663b157f1726f0d85abcb333b" => :sierra
    sha256 "e87155e00891f02aa430d1cc2eee45448a836f044f40baaae6c58192269abe72" => :el_capitan
    sha256 "b3e976be9e30376595330b6b8af1ececbd81e1bbb824c4b0fa60bf7b46dc8325" => :x86_64_linux
  end

  keg_only :versioned_formula

  option "without-cgo", "Build without cgo (also disables race detector)"
  option "without-race", "Build without race detector"

  depends_on :macos => :mountain_lion if OS.mac?

  resource "gotools" do
    url "https://go.googlesource.com/tools.git",
        :branch => "release-branch.go1.9"
  end

  # Don't update this unless this version cannot bootstrap the new version.
  resource "gobootstrap" do
    if OS.mac?
      url "https://storage.googleapis.com/golang/go1.7.darwin-amd64.tar.gz"
      sha256 "51d905e0b43b3d0ed41aaf23e19001ab4bc3f96c3ca134b48f7892485fc52961"
    elsif OS.linux?
      url "https://storage.googleapis.com/golang/go1.7.linux-amd64.tar.gz"
      sha256 "702ad90f705365227e902b42d91dd1a40e48ca7f67a2f4b2fd052aaa4295cd95"
    end
    version "1.7"
  end

  def install
    # Fixes: Error: Failure while executing: ../bin/ldd ../line-clang.elf: Permission denied
    unless OS.mac?
      chmod "+x", Dir.glob("src/debug/dwarf/testdata/*.elf")
      chmod "+x", Dir.glob("src/debug/elf/testdata/*-exec")
    end

    (buildpath/"gobootstrap").install resource("gobootstrap")
    ENV["GOROOT_BOOTSTRAP"] = buildpath/"gobootstrap"

    cd "src" do
      ENV["GOROOT_FINAL"] = libexec
      ENV["GOOS"]         = OS::NAME
      if build.without?("cgo")
        ENV["CGO_ENABLED"]  = "0"
      else
        ENV["CGO_ENABLED"]  = "1"
      end
      system "./make.bash", "--no-clean"
    end

    (buildpath/"pkg/obj").rmtree
    rm_rf "gobootstrap" # Bootstrap not required beyond compile.
    libexec.install Dir["*"]
    bin.install_symlink Dir[libexec/"bin/go*"]

    # Race detector only supported on amd64 platforms.
    # https://golang.org/doc/articles/race_detector.html
    if build.with?("cgo") && build.with?("race") && MacOS.prefer_64_bit?
      system bin/"go", "install", "-race", "std"
    end

    # Build and install godoc
    ENV.prepend_path "PATH", bin
    ENV["GOPATH"] = buildpath
    (buildpath/"src/golang.org/x/tools").install resource("gotools")
    cd "src/golang.org/x/tools/cmd/godoc/" do
      system "go", "build"
      (libexec/"bin").install "godoc"
    end
    bin.install_symlink libexec/"bin/godoc"
  end

  def caveats; <<~EOS
    A valid GOPATH is required to use the `go get` command.
    If $GOPATH is not specified, $HOME/go will be used by default:
      https://golang.org/doc/code.html#GOPATH

    You may wish to add the GOROOT-based install location to your PATH:
      export PATH=$PATH:#{opt_libexec}/bin
  EOS
  end

  test do
    (testpath/"hello.go").write <<~EOS
      package main

      import "fmt"

      func main() {
          fmt.Println("Hello World")
      }
    EOS
    # Run go fmt check for no errors then run the program.
    # This is a a bare minimum of go working as it uses fmt, build, and run.
    system bin/"go", "fmt", "hello.go"
    assert_equal "Hello World\n", shell_output("#{bin}/go run hello.go")

    # godoc was installed
    assert_predicate libexec/"bin/godoc", :exist?
    assert_predicate libexec/"bin/godoc", :executable?

    if build.with? "cgo"
      ENV["GOOS"] = "freebsd"
      system bin/"go", "build", "hello.go"
    end
  end
end
