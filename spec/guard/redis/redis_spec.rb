require 'spec_helper'
require 'guard/redis'

describe Guard::Redis do
  let(:guard) { described_class.new }

  describe "#start" do
    before(:each) do
      allow(guard).to receive(:last_operation_succeeded?).and_return(true)
    end

    it "calls IO.popen and passes in the executable" do
      expect(IO).to receive(:popen).with("redis-server -", "w+")
      guard.start
    end

    it "generates the config" do
      expect(guard).to receive(:config).and_return("daemonize yes\npidfile /tmp/redis.pid\nport 6379\n")
      guard.start
      sleep 1
      expect(guard.pidfile_path).to eql('/tmp/redis.pid')
    end

    it "writes the config to the server opened by IO" do
      server = double(IO.pipe).as_null_object
      expect(server).to receive(:write)
      expect(server).to receive(:close_write)
      allow(IO).to receive(:popen).and_yield(server)
      guard.start
    end
  end

  describe "#stop" do
    it "kills the process if a pid file is found" do
      pid = 5
      allow(guard).to receive(:redis_started?).and_return(true)
      allow(guard).to receive(:pid).and_return(pid)
      allow(guard).to receive(:process_running?).and_return(true)
      expect(Process).to receive(:kill).with("TERM", pid)
      guard.stop
    end

    it "does nothing if no pid file is found" do
      allow(guard).to receive(:pid).and_return(false)
      expect(Process).not_to receive(:kill)
      guard.stop
    end
  end

  describe "#reload" do
    it "runs stop and then start" do
      expect(guard).to receive(:stop).once
      expect(guard).to receive(:start).once
      guard.reload
    end
  end

  describe "#run_on_change" do
    it "reloads the process if specified in options" do
      allow(guard).to receive(:reload_on_change?).and_return(true)
      expect(guard).to receive(:reload).once
      guard.run_on_change([])
    end

    it "does not reload the process if specified in options" do
      allow(guard).to receive(:reload_on_change?).and_return(false)
      expect(guard).to receive(:reload).never
      guard.run_on_change([])
    end
  end

  describe "options" do
    describe "executable" do
      it "fetches the default executable if no option was passed in" do
        expect(guard.executable).to eql("redis-server")
      end

      it "fetches the overridden executable if one was provided" do
        subject = described_class.new({
          watchers: [],
          executable: "/usr/bin/redis-server"
        })
        expect(subject.executable).to eql("/usr/bin/redis-server")
      end
    end

    describe "port" do
      it "fetches the default port if no option was passed in" do
        expect(guard.port).to eq(6379)
      end

      it "fetches the overridden port if one was provided" do
        subject = described_class.new({
          watchers: [],
          port: 9999
        })
        expect(subject.port).to eq(9999)
      end
    end

    describe "pidfile path" do
      it "fetches the default pidfile path if no option was passed in" do
        expect(guard.pidfile_path).to match(/tmp\/redis.pid$/)
      end

      it "fetches the overridden pidfile path if one was provided" do
        subject = described_class.new({
          watchers: [],
          pidfile: "/var/pid/redis.pid"
        })
        expect(subject.pidfile_path).to eql("/var/pid/redis.pid")
      end
    end

    describe "reload_on_change" do
      it "fetches the default reload_on_change if no options was passed in" do
        expect(guard.reload_on_change?).to be(false)
      end

      it "fetches the overridden reload_on_change if one was provided" do
        subject = described_class.new({
          watchers: [],
          reload_on_change: true
        })
        expect(subject.reload_on_change?).to be(true)
      end
    end

    describe "capture_logging" do
      it "fetches the default capture_logging if no options was passed in" do
        expect(guard.capture_logging?).to be(false)
      end

      it "fetches the overridden capture_logging if one was provided" do
        subject = described_class.new({
          watchers: [],
          capture_logging: true
        })
        expect(subject.capture_logging?).to be(true)
      end
    end

    describe "logfile" do
      it "fetches the default logfile if no options was passed in" do
        expect(guard.logfile).to eql("stdout")
      end

      it "fetches the overridden logfile if one was provided" do
        subject = described_class.new({
          watchers: [],
          logfile: "log/redis.log"
        })
        expect(subject.logfile).to eql("log/redis.log")
      end

      it "fetches the standard logfile if capture_logging is enabled" do
        subject = described_class.new({
          watchers: [],
          capture_logging: true
        })
        expect(subject.logfile).to eql("log/redis_6379.log")
      end

      it "fetches the logfile with port if set and capture_logging is enabled" do
        subject = described_class.new({
          watchers: [],
          capture_logging: true,
          port: 9999
        })
        expect(subject.logfile).to eql("log/redis_9999.log")
      end

      it "should appear in the config if capture_logging is enabled " do
        subject = described_class.new({
          watchers: [],
          capture_logging: true,
          logfile: 'log/redis.log'
        })
        expect(subject.config).to eql("daemonize yes\npidfile /tmp/redis.pid\nport 6379\nlogfile log/redis.log")
      end
    end

    describe "shutdown_retries" do
      it "fetches the default shutdown_retries if no options was passed in" do
        expect(guard.shutdown_retries).to be(0)
      end

      it "fetches the overridden shutdown_retries if one was provided" do
        subject = described_class.new({
          watchers: [],
          shutdown_retries: 3
        })
        expect(subject.shutdown_retries).to be(3)
      end
    end

    describe "shutdown_wait" do
      it "fetches the default shutdown_wait if no options was passed in" do
        expect(guard.shutdown_wait).to be(0)
      end

      it "fetches the overridden shutdown_retries if one was provided" do
        subject = described_class.new({
          watchers: [],
          shutdown_wait: 5
        })
        expect(subject.shutdown_wait).to be(5)
      end
    end
  end
end
