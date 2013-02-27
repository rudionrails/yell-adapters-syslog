require 'spec_helper'

describe Yell::Adapters::Syslog do
  let(:logger) { Yell::Logger.new }
  let(:event) { Yell::Event.new(logger, 1, "Hello World" ) }

  before do
    Syslog.close if Syslog.opened?
  end

  shared_examples_for "a Syslog adapter" do
    let(:adapter) { Yell::Adapters::Syslog.new }

    it "should call Syslog correctly" do
      mock( Syslog ).log( Yell::Adapters::Syslog::Severities[subject], "Hello World" )

      adapter.write Yell::Event.new(logger, subject, "Hello World" )
    end
  end

  it_behaves_like( "a Syslog adapter" ) { subject { 0 } } # debug
  it_behaves_like( "a Syslog adapter" ) { subject { 1 } } # info
  it_behaves_like( "a Syslog adapter" ) { subject { 2 } } # warn
  it_behaves_like( "a Syslog adapter" ) { subject { 3 } } # error
  it_behaves_like( "a Syslog adapter" ) { subject { 4 } } # fatal
  it_behaves_like( "a Syslog adapter" ) { subject { 5 } } # unknown

  context "a new Yell::Adapters::Syslog instance" do
    subject { Yell::Adapters::Syslog.new }

    it { subject.ident.should == $0 }
    it { subject.options.should == (Syslog::LOG_PID | Syslog::LOG_CONS) }
    it { subject.facility.should be_nil }
  end

  context "OptionMap" do
    subject { Yell::Adapters::Syslog::OptionMap }

    its ( [:cons] ) { should == Syslog::LOG_CONS }
    its ( [:ndelay] ) { should == Syslog::LOG_NDELAY }
    its ( [:nowait] ) { should == Syslog::LOG_NOWAIT }
    its ( [:odelay] ) { should == Syslog::LOG_ODELAY }
    its ( [:perror] ) { should == Syslog::LOG_PERROR }
    its ( [:pid] ) { should == Syslog::LOG_PID }
  end

  context "FacilityMap" do
    subject { Yell::Adapters::Syslog::FacilityMap }

    # :console  => Syslog::LOG_CONSOLE, # described in 1.9.3 docu, but not defined
    # :lrp      => Syslog::LOG_LRP, # described in 1.9.3 docu, but not defined
    # :ntp      => Syslog::LOG_NTP, # described in 1.9.3 docu, but not defined
    # :security => Syslog::LOG_SECURITY, # described in 1.9.3 docu, but not defined
    it { subject[:auth].should == Syslog::LOG_AUTH }
    it { subject[:authpriv].should == Syslog::LOG_AUTHPRIV }
    it { subject[:cron].should == Syslog::LOG_CRON }
    it { subject[:daemon].should == Syslog::LOG_DAEMON }
    it { subject[:ftp].should == Syslog::LOG_FTP }
    it { subject[:kern].should == Syslog::LOG_KERN }
    it { subject[:mail].should == Syslog::LOG_MAIL }
    it { subject[:news].should == Syslog::LOG_NEWS }
    it { subject[:syslog].should == Syslog::LOG_SYSLOG }
    it { subject[:user].should == Syslog::LOG_USER }
    it { subject[:uucp].should == Syslog::LOG_UUCP }
    it { subject[:local0].should == Syslog::LOG_LOCAL0 }
    it { subject[:local1].should == Syslog::LOG_LOCAL1 }
    it { subject[:local2].should == Syslog::LOG_LOCAL2 }
    it { subject[:local3].should == Syslog::LOG_LOCAL3 }
    it { subject[:local4].should == Syslog::LOG_LOCAL4 }
    it { subject[:local5].should == Syslog::LOG_LOCAL5 }
    it { subject[:local6].should == Syslog::LOG_LOCAL6 }
    it { subject[:local7].should == Syslog::LOG_LOCAL7 }
  end

  context :ident do
    subject { Yell::Adapters::Syslog.new }

    it "should be passed" do
      mock.proxy( Syslog ).open( "my ident", anything, anything )

      subject.ident = "my ident"
      subject.write event
    end
  end

  context :options do
    subject { Yell::Adapters::Syslog.new }

    it "should be passed" do
      mock.proxy( Syslog ).open( anything, Syslog::LOG_NDELAY, anything )

      subject.options = :ndelay
      subject.write event
    end

    it "should work with multiple params" do
      mock.proxy( Syslog ).open( anything, Syslog::LOG_PID|Syslog::LOG_NDELAY, anything )

      subject.options = [:pid, :ndelay]
      subject.write event
    end
  end

  context :facility do
    subject { Yell::Adapters::Syslog.new }

    it "should be passed" do
      mock.proxy( Syslog ).open( anything, anything, Syslog::LOG_USER )

      subject.facility = :user
      subject.write event
    end

    it "should work with multiple params" do
      mock.proxy( Syslog ).open( anything, anything, Syslog::LOG_DAEMON|Syslog::LOG_USER )

      subject.facility = [:daemon, :user]
      subject.write event
    end
  end

end

