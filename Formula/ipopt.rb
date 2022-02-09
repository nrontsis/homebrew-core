class Ipopt < Formula
  desc "Interior point optimizer"
  homepage "https://coin-or.github.io/Ipopt/"
  url "https://github.com/coin-or/Ipopt/archive/releases/3.14.5.tar.gz"
  sha256 "9ebbbbf14a64e998e3fba5d2662a8f9bd03f97b1406017e78ae54e5d105ae932"
  license "EPL-1.0"
  head "https://github.com/coin-or/Ipopt.git", branch: "stable/3.14"

  bottle do
    sha256 cellar: :any,                 arm64_monterey: "528bdc41edb3bc0153fd4ce293a64bbc9204300a45aa6b6d3a90dd32dccebbe1"
    sha256 cellar: :any,                 arm64_big_sur:  "8b8a7fb50e85fc0f97abc5c419067bc540ed8abb97c8c73e18be6ee24002397c"
    sha256 cellar: :any,                 monterey:       "51998e1458ad0eb332e8489e484cfb1b5d73b7b3cc3b5cdbd56fb91ae486cfdb"
    sha256 cellar: :any,                 big_sur:        "c5d511fad958c0d221732869da0b15fc58cdc3219990390ec64071f265d81b9b"
    sha256 cellar: :any,                 catalina:       "0db189b8ec4400d10f16d7f5be8181dcb53f0f7483983a24e8b04a68a8183379"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "fd8cb54e6eef7a03510681f2dcefeb96558ec3c5ff17d660562f2ad457fedd31"
  end

  depends_on "openjdk" => :build
  depends_on "pkg-config" => [:build, :test]
  depends_on "ampl-mp"
  depends_on "gcc" # for gfortran
  depends_on "openblas"
  depends_on "mumps-seq"

  resource "test" do
    url "https://github.com/coin-or/Ipopt/archive/releases/3.14.5.tar.gz"
    sha256 "9ebbbbf14a64e998e3fba5d2662a8f9bd03f97b1406017e78ae54e5d105ae932"
  end

  def install
    ENV.delete("MPICC")
    ENV.delete("MPICXX")
    ENV.delete("MPIFC")

    args = [
      "--disable-debug",
      "--disable-dependency-tracking",
      "--disable-silent-rules",
      "--enable-shared",
      "--prefix=#{prefix}",
      "--with-blas=-L#{Formula["openblas"].opt_lib} -lopenblas",
      "--with-mumps-cflags=-I#{Formula["mumps-seq"].opt_include}/",
      "--with-mumps-lflags=-L#{Formula["mumps-seq"].opt_lib} -ldmumps -lmpiseq -lmumps_common -lopenblas -lpord",
      "--with-asl-cflags=-I#{Formula["ampl-mp"].opt_include}/asl",
      "--with-asl-lflags=-L#{Formula["ampl-mp"].opt_lib} -lasl",
    ]

    system "./configure", *args
    system "make"

    ENV.deparallelize
    system "make", "install"
  end

  test do
    testpath.install resource("test")
    pkg_config_flags = `pkg-config --cflags --libs ipopt`.chomp.split
    system ENV.cxx, "examples/hs071_cpp/hs071_main.cpp", "examples/hs071_cpp/hs071_nlp.cpp", *pkg_config_flags
    system "./a.out"
    system "#{bin}/ipopt", "#{Formula["ampl-mp"].opt_pkgshare}/example/wb"
  end
end
