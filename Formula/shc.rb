class Shc < Formula
  desc "Shell Script Compiler"
  homepage "https://neurobin.github.io/shc"
  url "https://github.com/neurobin/shc/archive/3.9.6.tar.gz"
  sha256 "da6a2a3ff4c356a61e086c616561bf681489993cab00c426bad0cfd703a68063"
  head "https://github.com/neurobin/shc.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "f7c53fd5fa9c86057260ad66961406b4579738b30091d7ca6899eb5349013b0c" => :sierra
    sha256 "c54ddaec872f8c3613c53f7b1653250f3a11ad6db789418f8921be96fff6e8a3" => :el_capitan
    sha256 "0b40ee06c9a5db74e302be41adea362975bf86c9c5e6290da13a623341e4468d" => :yosemite
    sha256 "6cdfa9e5a6d85c5363ccf1f938e733b4298369fd7d65c86afb91aa0254c4ada8" => :x86_64_linux # glibc 2.19
  end

  def install
    system "./configure"
    system "make", "install", "prefix=#{prefix}"
    pkgshare.install "test"
  end

  test do
    (testpath/"test.sh").write <<-EOS.undent
      #!/bin/sh
      echo hello
      exit 0
    EOS
    system bin/"shc", "-f", "test.sh", "-o", "test"
    assert_equal "hello", shell_output("./test").chomp
  end
end
