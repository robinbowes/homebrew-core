class Cppinsights < Formula
  desc "See your source code with the eyes of a compiler"
  homepage "https://cppinsights.io/"
  url "https://github.com/andreasfertig/cppinsights/archive/refs/tags/v_0.9.tar.gz"
  sha256 "cebb6a062677ee3975ff757e4300a17f42e3fab6da02ad01f3f141fb91f09301"
  license "MIT"

  depends_on "cmake" => :build
  depends_on "llvm@15"

  on_macos do
    depends_on "llvm" => :build if DevelopmentTools.clang_build_version <= 1300
  end

  fails_with :clang do
    build 1300
    cause "Requires C++20"
  end

  def install
    ENV.llvm_clang if ENV.compiler == :clang && DevelopmentTools.clang_build_version <= 1300
    ENV.remove "HOMEBREW_INCLUDE_PATHS", Formula["llvm"].opt_include
    ENV.remove "HOMEBREW_LIBRARY_PATHS", Formula["llvm"].opt_lib

    system "cmake", "-S", ".", "-B", "build", *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    (testpath/"test.cpp").write <<~EOS
      int main() {
        int arr[5]{2,3,4};
      }
    EOS
    assert_match "{2, 3, 4, 0, 0}", shell_output("#{bin}/insights ./test.cpp")
  end
end
