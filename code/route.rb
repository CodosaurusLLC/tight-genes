class Route
  CITIES = %w(AMS AND BRU LIS LUX MAD MTC PAR)

  def self.run(how_many = 10)
    @@generations = 0
    pop = initial_population(how_many)
    while ! done?(pop) do
      p1, p2 = select_breeders(pop)
      pop = new_population(p1, p2, how_many)
      pop.each { |p| p.mutate }
    end
    pop
  end

  attr_accessor :stops
  def initialize(stops=nil)
    @stops = stops || CITIES.shuffle
  end

  def self.initial_population(how_many)
    population = []
    for i in 1..how_many
      population.append(self.new)
    end
    return population
  end  

  @@best_route = nil
  @@best_fitness = -100_000

  def self.done?(population)
    @@generations += 1
    puts "gen: #{@@generations}, best: #{@@best_fitness}"
    puts "(#{@@best_route.stops.join (' -> ')})" if @@best_route
    better = population.select { |r| r.fitness > @@best_fitness }
    if better.any?
      @@best_route = better.sort_by(&:fitness).last
      @@best_fitness = @@best_route.fitness
      @@generations = 0
      puts "RESET: #{@@best_route.stops.join (' -> ')} (#{@@best_fitness})" 
      return false
    else
      return @@generations >= 100
    end
  end

  def self.select_breeders(pop)
    total = -pop.map(&:fitness).sum
    # set p2 = p1 so until-loop will start
    p2 = p1 = pick_winner(pop, rand(total))
    p2 = pick_winner(pop, rand(total)) until p2 != p1
    [p1, p2]
  end

  def self.pick_winner(pop, num)
    total = 0
    pop.each do |p|
      total -= p.fitness
      return p if total > num
    end
  end

  def self.new_population(p1, p2, how_many)
    population = []
    for i in 1..how_many
      population.append(self.breed(p1, p2))
    end
    return population
  end
  
  def self.breed(p1, p2)
    xover = rand(CITIES.length + 1)
    cities = []
    cities[0 .. (xover - 1)] =
      p1.stops.slice(0, xover)
    cities[xover .. (CITIES.length - 1)] =
      p2.stops.reject { |city| cities.member?(city) }
    return Route.new(cities)
  end

  def fitness
    -total_distance
  end

  def total_distance
    stops.
      each_cons(2).
      to_a.
      map { |src, dst| distance(src, dst) }.
      sum +
      distance(stops.first, stops.last)
  end

  def distance(src, dst)
    src, dst = dst, src if src > dst
    DISTANCES[src][dst]
  end

  DISTANCES = {
    "AMS" => {
      "AND" => 1357, "BRU" =>  210, "LIS" => 2233, "LUX" =>  417,
      "MAD" => 1773, "MTC" => 1421, "PAR" =>  502
    },
    "AND" => {
      "BRU" => 1162, "LIS" => 1232, "LUX" => 1178,
      "MAD" =>  613, "MTC" =>  653, "PAR" =>  862
    },
    "BRU" => {
      "LIS" => 2038, "LUX" =>  213, "MAD" => 1577,
      "MTC" => 1200, "PAR" =>  307
    },
    "LIS" => { "LUX" => 2153, "MAD" =>  625, "MTC" => 1838, "PAR" => 1739 },
    "LUX" => { "MAD" => 1691, "MTC" => 1041, "PAR" =>  386 },
    "MAD" => { "MTC" => 1288, "PAR" => 1278 },
    "MTC" => { "PAR" =>  956 },
  }

  def mutate()
    i1 = rand(CITIES.length)
    i2 = rand(CITIES.length)
    stops[i1], stops[i2] = [stops[i2], stops[i1]]
  end

end
