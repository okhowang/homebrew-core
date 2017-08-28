class Lzop < Formula
  desc "File compressor"
  homepage "https://www.lzop.org/"
  url "https://dl.bintray.com/homebrew/mirror/lzop-1.04.tar.gz"
  mirror "https://www.lzop.org/download/lzop-1.04.tar.gz"
  sha256 "7e72b62a8a60aff5200a047eea0773a8fb205caf7acbe1774d95147f305a2f41"

  bottle do
    cellar :any
    sha256 "73c2ce334be9317ca79509aec3acef2fa1eff0ffb69fdc10b3850b7f51101f72" => :sierra
    sha256 "26e49bf0d06fb60d7cd5c431634966f28993edc250c4d06b0db26b28aae3cd0d" => :el_capitan
    sha256 "d9e12c4bb51c43dd306d5283fde5c3350e3e1f7f1d48c05c831a57b058db1354" => :yosemite
    sha256 "1f26b675b0867eb9f6095d1b3bc61155e06dd05835848a6718def97168b6d4d7" => :x86_64_linux # glibc 2.19
  end

  depends_on "lzo"

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    path = testpath/"test"
    text = "This is Homebrew"
    path.write text

    system "#{bin}/lzop", "test"
    assert File.exist?("test.lzo")
    rm path

    system "#{bin}/lzop", "-d", "test.lzo"
    assert_equal text, path.read
  end
end
