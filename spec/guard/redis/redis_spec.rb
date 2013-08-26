require 'spec_helper'
require 'guard/redis'

describe Guard::Redis do
  let(:guard) { described_class.new }

  describe "#start" do
    before(:each) do
      guard.stub(:last_operation_succeeded?).and_return(true)
    end

    it "calls IO.popen and passes in the executable" do
      IO.should_receive(:popen).with("redis-server -", "w+")
      guard.start
    end

    it "generates the config" do
      guard.should_receive(:config).and_return("daemonize yes\npidfile /tmp/redis.pid\nport 6379\n")
      guard.start
      sleep 1
      guard.pidfile_path.should eql('/tmp/redis.pid')
    end

    it "writes the config to the server opened by IO" do
      server = double(IO.pipe).as_null_object
      server.should_receive(:write)
      server.should_receive(:close_write)
      server.should_receive(:pid).and_return(9999)
      IO.stub(:popen).and_yield(server)
      guard.start
    end
  end

  describe "#stop" do
    it "kills the process if a pid file is found" do
      pid = 5
      guard.stub(:pid).and_return(pid)
      guard.stub(:process_running?).and_return(true)
      Process.should_receive(:kill).with("TERM", pid)
      guard.stop
    end

    it "does nothing if no pid file is found" do
      guard.stub(:pid).and_return(false)
      Process.should_not_receive(:kill)
      guard.stop
    end
  end

  describe "#reload" do
    it "runs stop and then start" do
      guard.should_receive(:stop).once
      guard.should_receive(:start).once
      guard.reload
    end
  end

  describe "#run_on_change" do
    it "reloads the process if specified in options" do
      guard.stub(:reload_on_change?).and_return(true)
      guard.should_receive(:reload).once
      guard.run_on_change([])
    end

    it "does not reload the process if specified in options" do
      guard.stub(:reload_on_change?).and_return(false)
      guard.should_receive(:reload).never
      guard.run_on_change([])
    end
  end

  describe "options" do
    describe "executable" do
      it "fetches the default executable if no option was passed in" do
        guard.executable.should == "redis-server"
      end

      it "fetches the overridden executable if one was provided" do
        subject = described_class.new([], { :executable => "/usr/bin/redis-server" })
        subject.executable.should == "/usr/bin/redis-server"
      end
    end

    describe "port" do
      it "fetches the default port if no option was passed in" do
        guard.port.should == 6379
      end

      it "fetches the overridden port if one was provided" do
        subject = described_class.new([], { :port => 9999 })
        subject.port.should == 9999
      end
    end

    describe "pidfile path" do
      it "fetches the default pidfile path if no option was passed in" do
        guard.pidfile_path.should =~ /tmp\/redis.pid$/
      end

      it "fetches the overridden pidfile path if one was provided" do
        subject = described_class.new([], { :pidfile => "/var/pid/redis.pid" })
        subject.pidfile_path.should == "/var/pid/redis.pid"
      end
    end

    describe "reload_on_change" do
      it "fetches the default reload_on_change if no options was passed in" do
        guard.reload_on_change?.should == false
      end

      it "fetches the overridden reload_on_change if one was provided" do
        subject = described_class.new([], { :reload_on_change => true })
        subject.reload_on_change?.should == true
      end
    end

    describe "capture_logging" do
      it "fetches the default capture_logging if no options was passed in" do
        guard.capture_logging?.should == false
      end

      it "fetches the overridden capture_logging if one was provided" do
        subject = described_class.new([], { :capture_logging => true })
        subject.capture_logging?.should == true
      end
    end

    describe "logfile" do
      it "fetches the default logfile if no options was passed in" do
        guard.logfile.should == "stdout"
      end

      it "fetches the overridden logfile if one was provided" do
        subject = described_class.new([], { :logfile => "log/redis.log" })
        subject.logfile.should == "log/redis.log"
      end

      it "fetches the standard logfile if capture_logging is enabled" do
        subject = described_class.new([], { :capture_logging => true })
        subject.logfile.should == "log/redis_6379.log"
      end

      it "fetches the logfile with port if set and capture_logging is enabled" do
        subject = described_class.new([], { :capture_logging => true, :port => 9999 })
        subject.logfile.should == "log/redis_9999.log"
      end

      it "should appear in the config if capture_logging is enabled " do
        subject = described_class.new([], { :capture_logging => true, :logfile => 'log/redis.log' })
        subject.config.should == "daemonize yes\npidfile /tmp/redis.pid\nport 6379\nlogfile log/redis.log"
      end
    end

    describe "shutdown_retries" do
      it "fetches the default shutdown_retries if no options was passed in" do
        guard.shutdown_retries.should == 0
      end

      it "fetches the overridden shutdown_retries if one was provided" do
        subject = described_class.new([], { :shutdown_retries => 3 })
        subject.shutdown_retries.should == 3
      end
    end

    describe "shutdown_wait" do
      it "fetches the default shutdown_wait if no options was passed in" do
        guard.shutdown_wait.should == 0
      end

      it "fetches the overridden shutdown_retries if one was provided" do
        subject = described_class.new([], { :shutdown_wait => 5 })
        subject.shutdown_wait.should == 5
      end
    end
  end
end
