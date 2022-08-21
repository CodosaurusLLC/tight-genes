class Evolver
  attr_reader :klazz, :header, :how_many

  def initialize(klazz, options={})
    @klazz = klazz
    @header = options[:header] || klazz::REPORT_HEADER rescue nil  # blank OK
    @how_many = options[:how_many] || 10
  end

  def evolve()
    pop = initial_pop().sort_by(&:fitness).reverse
    generations = 1
    report(generations, pop)
    while not klazz.done?(pop, generations)
      breeders = klazz.select_breeders(pop)
      pop = breed(breeders)
      pop.each { |indiv| indiv.maybe_mutate }
      pop = pop.sort_by(&:fitness).reverse
      generations += 1
      report(generations, pop)
    end
    puts "Done"
  end

  def initial_pop()
    (1..how_many).map { |_| klazz.new() }
  end

  def report(generations, pop)
    puts "After #{generations} generations, we have:"
    puts header
    pop.each { |indiv| indiv.report() }
    puts
  end

  def breed(breeders)
    (1..how_many).map { |_| klazz.combine(breeders) }
  end
end
