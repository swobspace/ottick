require 'spec_helper'

describe 'TicketSetup' do
  it "creates a new Ticket instance with Savon::Client" do
    ticket = Ottick::Ticket.new()
    expect(ticket).to be_a_kind_of Ottick::Ticket
    client = ticket.client
    expect(client).to be_a_kind_of Savon::Client
  end

  it "creates a new Ticket instance with default options" do
    allow(Ottick).to receive(:wsdl) {'TicketGenerator.wsdl'}
    allow(Ottick).to receive(:endpoint) {'http://localhost/anywhere'}

    ticket = Ottick::Ticket.new()
    options = ticket.options
    expect(options).to be_a_kind_of Hash
    expect(options[:wsdl]).to eq('TicketGenerator.wsdl')
    expect(options[:endpoint]).to eq('http://localhost/anywhere')
    expect(options[:env_namespace]).to eq(:soapenv)
    options[:convert_request_keys_to] == :camelcase
    expect(options).not_to include(:basic_auth)
  end

  it "creates a new Ticket instance with basic http authentication" do
    allow(Ottick).to receive(:http_auth_user) {'webservice'}
    allow(Ottick).to receive(:http_auth_passwd) {'very secret'}

    ticket = Ottick::Ticket.new()
    expect(ticket.options).to include(:basic_auth)
    expect(ticket.options[:basic_auth]).to include("webservice", "very secret")
  end

  it "options from Ticket.new with http_auth_* stuff should raise error" do
    expect { Ottick::Ticket.new(http_auth_user: "xxx") }.to raise_error(RuntimeError)
    expect { Ottick::Ticket.new(http_auth_passwd: "yyy") }.to raise_error(RuntimeError)
  end

  it "options from Ticket.new doesn't contain otrs_user and otrs_passwd" do
    ticket = Ottick::Ticket.new(otrs_user: "zzz", otrs_passwd: "aaa")
    expect(ticket.options).not_to include(:otrs_user)
    expect(ticket.options).not_to include(:otrs_passwd)
  end
  
  
end
