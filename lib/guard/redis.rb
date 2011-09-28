require 'guard'
require 'guard/guard'

module Guard
  class Redis < Guard
    def start
      puts "Starting Redis on port #{port}"
      IO.popen("#{executable} -", 'w+') do |server|
        server.write(config)
        server.close_write
      end
      puts "Redis is running with PID #{pid}"
      $?.success?
    end

    def stop
      if pid
        puts "Sending TERM signal to Redis (#{pid})"
        Process.kill("TERM", pid)
        true
      end
    end

    def reload
      stop
      start
    end

    def run_all
      true
    end

    def run_on_change(paths)
      true
    end

    def pidfile_path
      options.fetch(:pidfile) {
        File.expand_path('tmp/redis.pid', File.dirname(__FILE__))
      }
    end

    def config
      <<"END"
daemonize yes
pidfile #{pidfile_path}
port #{port}
END
    end

    def pid
      File.exist?(pidfile_path) && File.read(pidfile_path).to_i
    end

    def executable
      options.fetch(:executable) { 'redis-server' }
    end

    def port
      options.fetch(:port) { 6379 }
    end
  end
end