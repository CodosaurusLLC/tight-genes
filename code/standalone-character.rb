class Character
  attr_accessor :str, :int, :dex, :con, :wis, :cha, :fit

  def self.evolve()
    how_many = 10
    pop = self.create(how_many)
    generations = 1
    while not done?(pop)
      parent_1, parent_2 = self.select_breeders(pop)
      pop = self.new_population(parent_1, parent_2, how_many)
      pop.each { |indiv| indiv.maybe_mutate }
      generations += 1
    end
    puts "After #{generations} generations, we have:"
    puts pop.sort_by(&:fitness).inspect
  end

  def self.create(how_many)
    population = []
    for i in 1..how_many
      population.append(self.new)
    end
    return population
  end  

  def initialize()
    @str = roll(3, 6)
    @int = roll(3, 6)
    @dex = roll(3, 6)
    @con = roll(3, 6)
    @wis = roll(3, 6)
    @cha = roll(3, 6)
  end

  def roll(num_dice, die_size)
    total = 0
    for i in 1..num_dice
      total += rand(die_size) + 1
    end
    total
  end

  def self.done?(population)
    population.any? { |indiv| indiv.fitness >= 1021 }
  end

  def fitness()
    return fit if fit  # may be already cached
    # stats = [str, con, dex, int, wis, cha]  # for fighters
    stats = [int, wis, dex, con, cha, str]  # for wizards
    @fit =  # cache it
      (0..5).
      map { |idx| stats[idx] * 2 ** (5 - idx) }.
      sum
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
    char = self.new
    char.str = rand(2) == 1 ? p1.str : p2.str
    char.int = rand(2) == 1 ? p1.int : p2.int
    char.dex = rand(2) == 1 ? p1.dex : p2.dex
    char.con = rand(2) == 1 ? p1.con : p2.con
    char.wis = rand(2) == 1 ? p1.wis : p2.wis
    char.cha = rand(2) == 1 ? p1.cha : p2.cha
    return char
  end

  def maybe_mutate()
    @str = maybe_mutate_stat(@str)
    @int = maybe_mutate_stat(@int)
    @dex = maybe_mutate_stat(@dex)
    @con = maybe_mutate_stat(@con)
    @wis = maybe_mutate_stat(@wis)
    @cha = maybe_mutate_stat(@cha)
    @fit = nil  # in case it's been memoized
    # no return value needed
  end

  def maybe_mutate_stat(stat)
    (stat + rand(3) - 1).clamp(3, 18)
  end
end
