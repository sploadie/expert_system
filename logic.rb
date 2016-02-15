require_relative 'facts'
require_relative 'rule'

# Check this out

def logic_this(arg_facts, arg_rules, query)
  original_facts = Facts.new(*arg_facts)

  puts 'Original Facts:'
  puts original_facts.to_s

  rulesets = [arg_rules]
  rulesets.map! do |ruleset|
    new_ruleset = []
    ruleset.each do |condition, reaction_array|
      raise 'reaction array is empty!' if reaction_array.empty?
      reaction = reaction_array.shift
      # if reaction_array is a clone, use below
      # reaction = ruleset[condition].shift
      rulesets << ruleset.clone unless reaction_array.empty?
      new_ruleset << Rule.new(condition, reaction)
    end
    new_ruleset
  end

  puts ''
  puts 'Rulesets:'
  puts '===================='

  begin
    all_facts = rulesets.map do |ruleset|

      # debug v
      puts 'Rules:'
      puts ruleset.map(&:to_s).join('\n')
      puts ''
      puts 'Facts:'
      # debug ^

      ruleset_facts = original_facts.clone
      reaction_occured = true
      temp_facts = nil
      while ruleset_facts.to_s != temp_facts.to_s
        temp_facts = ruleset_facts.clone
        ruleset.each { |rule| rule.apply_to(ruleset_facts) }
        # debug v
        puts '-> ' + temp_facts.to_s
        sleep 1
        # debug ^
      end

      # debug v
      puts '===================='
      # debug ^

      ruleset_facts
    end
  rescue Exception => e
    p e
  end

  puts ''
  puts 'Ruleset Facts:'
  all_facts.each do |ruleset_facts|
    puts ruleset_facts.to_s
  end

  final_facts = all_facts.first()
  all_facts.each do |ruleset_facts|
    Facts::LETTERS.each do |let|
      final_facts[let] = :ambiguous if final_facts[let] != ruleset_facts[let]
    end
  end
  Facts::LETTERS.each do |let|
    final_facts[let] = false if final_facts[let].nil?
  end

  puts ''
  puts 'Final Facts:'
  puts final_facts.to_s
end

# Examples

arg_facts = [:A, :B]
arg_rules = {'facts[:A]' => [{C: true}, {D: true}]}
# arg_rules = {'facts[:A]' => [{X: true}, {Y: true}], 'facts[:X]' => [{C: true}, {D: true}]}
query = [:A, :B, :C, :D]

logic_this(arg_facts, arg_rules, query)