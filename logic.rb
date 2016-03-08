require_relative 'facts'
require_relative 'rule'
require_relative 'color'

$VERBOSE = false
$SLOW = false

# Check this out

def clone_ruleset(ruleset)
  new_ruleset = {}
  ruleset.each do |condition, reaction_array|
    new_ruleset[condition] = reaction_array.clone
  end
  new_ruleset
end

def logic_this(arg_facts, arg_rules, query)
  original_facts = Facts.new(*arg_facts)
  if $VERBOSE
    puts 'Original Facts:'
    puts original_facts.to_s
  end
  new_rulesets = []
  rulesets = [arg_rules]
  i = 0
  # Creates all possible rule scenarios - OR/XOR multiplied by each other
  while rulesets[i] != nil
    ruleset = rulesets[i]
    new_ruleset = []
    ruleset.each do |condition, reaction_array|
      raise 'reaction array is empty!' if reaction_array.empty?
      new_ruleset << Rule.new(condition, reaction_array.first)
      if reaction_array.count > 1
        temp_ruleset = clone_ruleset(ruleset)
        temp_ruleset[condition].shift
        rulesets << temp_ruleset
      end
    end
    new_rulesets << new_ruleset
    i += 1
  end

  if $VERBOSE
    sleep 0.5 if $SLOW
    puts ''
    puts 'Rulesets:'
    puts '@==================@'
    puts '--------------------'
  end

  begin
    all_facts = new_rulesets.map do |ruleset|

      if $VERBOSE
        puts 'Rules:'
        puts ruleset.map(&:to_s).join("\n")
        sleep 0.5 if $SLOW
        puts ''
        puts 'Facts:'
      end

      ruleset_facts = original_facts.clone
      reaction_occured = true
      temp_facts = :nothing
      while ruleset_facts.to_s != temp_facts.to_s
        temp_facts = ruleset_facts.clone
        ruleset.each { |rule| rule.apply_to(ruleset_facts) }

        if $VERBOSE
          puts '-> ' + temp_facts.to_s
          sleep 0.5 if $SLOW
        end
      end

      if $VERBOSE
        puts '--------------------'
      end

      ruleset_facts
    end
  rescue Exception => e
    puts "Rules Error: #{e.message}".red
    exit
  end

  if $VERBOSE
    # puts ''
    # puts 'All Ruleset Facts:'
    # puts all_facts.map(&:to_s).join("\n")
    puts '@==================@'
    sleep 0.5 if $SLOW
    puts ''
    puts 'Unique Ruleset Facts:'
    puts all_facts.map(&:to_s).uniq.join("\n")
  end

  final_facts = all_facts.first()
  all_facts.each do |ruleset_facts|
    Facts::LETTERS.each do |let|
      final_fact_val   = final_facts[let]   ? true : false
      ruleset_fact_val = ruleset_facts[let] ? true : false
      final_facts[let] = :ambiguous if final_fact_val != ruleset_fact_val
    end
  end

  if $VERBOSE
    sleep 0.5 if $SLOW
    puts ''
    puts 'Final Facts:'
    puts final_facts.to_s
    sleep 0.5 if $SLOW
    puts ''
  end

  Facts::LETTERS.each do |let|
    final_facts[let] = false if final_facts[let].nil?
  end

  puts 'Query Response: '.green + final_facts.facts_for(query)
end

# Examples
# $VERBOSE = true
# $SLOW = true
# arg_facts = [:A, :B]
# # Not Flawed
# # arg_rules = {'facts[:A]' => [{C: true}, {D: true}]}
# # arg_rules = {'facts[:A]' => [{X: true}, {Y: true}], 'facts[:X]' => [{C: true}, {D: true}]}
# arg_rules = {'facts[:A]' => [{X: true}, {Y: true}], 'facts[:X]' => [{C: true}, {D: true}], 'facts[:Y]' => [{M: true}, {N: true}]}
# # Flawed
# # arg_rules = {'facts[:B]' => [{B: false}]}
# query = [:A, :B, :C, :D, :M, :N, :Z]

# logic_this(arg_facts, arg_rules, query)