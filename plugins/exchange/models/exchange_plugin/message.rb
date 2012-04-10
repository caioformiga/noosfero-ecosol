class ExchangePlugin::Message < Noosfero::Plugin::ActiveRecord

  belongs_to :exchange, :class_name => "ExchangePlugin::Exchange"
  belongs_to :enterprise_sender, :class_name => "Enterprise"
  belongs_to :enterprise_recipient, :class_name => "Enterprise"
  belongs_to :person_sender, :class_name => "Person"

  #validates_presence_of :enterprise_sender 
  #validates_presence_of :enterprise_recipient 
  #validates_presence_of :person_sender

  def self.new_exchange_message(exchange, enterprise_sender, enterprise_recipient, person_sender, body)
    m = self.new
    m.exchange = exchange
    m.exchange_state = exchange.state
    m.enterprise_sender = enterprise_sender
    m.enterprise_recipient = enterprise_recipient
    m.person_sender = person_sender  
    m.body = body 
    m.save!
    m
  end

end
