class Recipe
  attr_accessor :ratio, :tolerance, :abv, :sweet, :fit

  def self.evolve()
    how_many = 10
    pop = self.create(how_many)
    generations = 1
    report(generations, pop)
    while not done?(pop)
      parent_1, parent_2 = self.select_breeders(pop)
      pop = self.new_population(parent_1, parent_2, how_many)
      pop.each { |indiv| indiv.maybe_mutate }
      generations += 1
      report(generations, pop)
    end
  end

  def self.report(generations, pop)
    puts "After #{generations} generations, we have:"
    puts "Ratio  Tolerance  %ABV  Sweet     Fit"
    pop.sort_by(&:fitness).reverse.each do |rec|
      printf("%5.2f       %4.1f  %4.1f   %4.1f  %6.1f\n",
             rec.ratio, rec.tolerance, rec.abv, rec.sweet, rec.fit)
    end
    puts
  end

  def self.create(how_many)
    population = []
    for i in 1..how_many
      population.append(self.new)
    end
    return population
  end  

  def initialize()
    # water-to-honey ratio of 1.5 to 15
    @ratio = roll(3, 10) / 2.0
    # alcohol tolerance of 6-20
    @tolerance = 4 + roll(2, 8)
  end

  def roll(num_dice, die_size)
    total = 0
    for i in 1..num_dice
      total += rand(die_size) + 1
    end
    total
  end

  def self.done?(population)
    population.any? { |indiv| indiv.fitness >= 99.9 }
  end

  def fitness()
    return fit if fit  # may be already cached
    target_abv = 16
    target_sweet = 35
    @abv, @sweet = evaluate()
    abv_off = (target_abv - abv).abs
    sweet_off = (target_sweet - sweet).abs
    off = abv_off ** 2 + sweet_off ** 2
    @fit = 100 - off;
  end

  def evaluate()
    # use 1 liter water, and the appropriate amount of honey
    honey_volume = 1.0 / ratio
    total_mass = honey_volume * 1.425 + 1
    total_volume = honey_volume + 1
    og = total_mass / total_volume
    potential = (og - 1) * 1000 / 7.62
    abv = [tolerance, potential].min
    fg = og - abv * 7.62 / 1000
    return abv, (fg - 1) * 1000
  end

  def self.select_breeders(population)
    population.
      sort_by(&:fitness).
      reverse.
      take(2)
  end

  def self.new_population(p1, p2, how_many)
    population = []
    for i in 1..how_many
      population.append(self.breed(p1,p2))
    end
    return population
  end

  def self.breed(p1, p2)
    rec = self.new
    rec.ratio     = rand(2) == 1 ? p1.ratio     : p2.ratio
    rec.tolerance = rand(2) == 1 ? p1.tolerance : p2.tolerance
    return rec
  end

  def maybe_mutate()
    @ratio = maybe_mutate_stat(@ratio, 1.5, 15)
    @tolerance = maybe_mutate_stat(@tolerance, 6, 20)
    @fit = nil  # in case it's been memoized
    # no return value needed
  end

  def maybe_mutate_stat(stat, min, max)
    val = stat * (0.79 + roll(2, 20) / 100.0)
    return max if val > max
    return min if val < min
    return val
  end
end

