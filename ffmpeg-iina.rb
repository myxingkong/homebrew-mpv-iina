# Last check with upstream: 042325cd385225e055e2ccf676abe0072cd38dcb <ffmpeg: update 6.0_2 bottle>
# https://github.com/Homebrew/homebrew-core/blob/master/Formula/f/ffmpeg.rb

class FfmpegIina < Formula
  desc "Play, record, convert, and stream audio and video"
  homepage "https://ffmpeg.org/"
  url "https://ffmpeg.org/releases/ffmpeg-7.1.1.tar.xz"
  sha256 "733984395e0dbbe5c046abda2dc49a5544e7e0e1e2366bba849222ae9e3a03b1"
  head "https://github.com/FFmpeg/FFmpeg.git", branch: "master"

  keg_only <<EOS
it is intended to only be used for building IINA.
This formula is not recommended for daily use and has no binaraies (ffmpeg, ffplay etc.)
EOS

  depends_on "pkg-config" => :build
  depends_on "dav1d"
  depends_on "fontconfig"
  depends_on "freetype"
  depends_on "frei0r"
  depends_on "gnutls"
  depends_on "libass"
  depends_on "libbluray"
  depends_on "libsoxr"
  depends_on "libvidstab"
  depends_on "rubberband"
  depends_on "snappy"
  depends_on "speex"
  # depends_on "tesseract"
  depends_on "xz"
  depends_on "zeromq"
  depends_on "zimg"
  depends_on "jpeg-xl" # for JPEG-XL format screenshot
  depends_on "webp" # for webp format screenshot

  on_intel do
    depends_on "nasm" => :build
  end

  uses_from_macos "bzip2"
  uses_from_macos "libxml2"
  uses_from_macos "zlib"

  def install

    # force ffmpeg to use the correct deployment target
    if Hardware::CPU.arm?
      ENV["MACOSX_DEPLOYMENT_TARGET"] = "11.0"
    elsif Hardware::CPU.intel?
      ENV["MACOSX_DEPLOYMENT_TARGET"] = "10.15"
    end
    
    args = %W[
      --prefix=#{prefix}
      --enable-shared
      --enable-pthreads
      --enable-version3
      --host-cflags=#{ENV.cflags}
      --host-ldflags=#{ENV.ldflags}
      --enable-ffplay
      --enable-gnutls
      --enable-gpl
      --enable-libbluray
      --enable-libdav1d
      --enable-librubberband
      --enable-libsnappy
      --disable-libtesseract
      --enable-libvidstab
      --enable-libxml2
      --enable-libfontconfig
      --enable-libfreetype
      --enable-frei0r
      --enable-libass
      --enable-libspeex
      --enable-libsoxr
      --enable-videotoolbox
      --enable-audiotoolbox
      --enable-libzmq
      --enable-libzimg
      --enable-libwebp
      --enable-libjxl
      --disable-libjack
      --disable-indev=jack
      --disable-programs
    ]


    args << "--enable-neon" if Hardware::CPU.arm?
    args << "--cc=#{ENV.cc}" if Hardware::CPU.intel?

    system "./configure", *args
    system "make", "install"

  end

  test do
    # Create an example mp4 file
    mp4out = testpath/"video.mp4"
    system bin/"ffmpeg", "-filter_complex", "testsrc=rate=1:duration=1", mp4out
    assert_predicate mp4out, :exist?
  end
end
