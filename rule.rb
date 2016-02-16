class Rule
  attr_reader :condition, :reaction

  def initialize(condition, reaction)
    raise 'condition must be a string' unless condition.is_a? String
    raise 'reaction must be an array'  unless reaction.is_a?  Hash
    @condition = condition
    @reaction  = reaction
  end

  def check_with(real_facts)
    facts = real_facts.clone
    eval "(#{@condition}) ? true : false"
  end

  def apply_to(real_facts)
    facts = real_facts.clone
    if eval "(#{@condition}) ? true : false"
      real_facts.apply @reaction
      return true
    end
    false
  end

  def to_h
    {condition: @condition, reaction: @reaction}
  end

  def to_s
    # "Condition: (#{@condition}) :: Reaction: #{@reaction}"
    c_str = @condition.gsub /facts\[\:(.)\]/, '\1'
    r_str = @reaction.map {|k,v| "#{k}=#{v}"}
    "#{c_str} => #{r_str.join(' ')}"
  end

  def method_missing(method, *args)
    {condition: @condition, reaction: @reaction}.send(method, *args)
  end
end
