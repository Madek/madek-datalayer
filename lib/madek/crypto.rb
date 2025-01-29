require 'open3'

module Madek
  module Crypto
    class ECKey 
      attr_reader :private_key
      attr_reader :public_key

      def initialize

        @private_key = Open3.popen3(
          "openssl ecparam -name prime256v1 -genkey -noout") {
            |stdin, stdout, stderr, wait_thr|
            stdin.close
            key = stdout.read; stdout.close
            err = stderr.read; stderr.close
            raise err unless wait_thr.value.success?
            key
          }

          @public_key = Open3.popen3("openssl ec -pubout") {
            |stdin, stdout, stderr, wait_thr|
            stdin.write(@private_key); stdin.close
            key = stdout.read; stdout.close
            err = stderr.read; stderr.close
            raise err unless wait_thr.value.success?
            key
          }
      end
    end
  end
end
