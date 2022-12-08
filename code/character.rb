class Character
  REPORT_HEADER = "Str  Int  Dex  Con  Wis  Cha   Fit"
  attr_accessor :str, :int, :dex, :con, :wis, :cha, :fit

  def initialize()
    @str = roll(3, 6)
    @int = roll(3, 6)
    @dex = roll(3, 6)
    @con = roll(3, 6)
    @wis = roll(3, 6)
    @cha = roll(3, 6)
  end

  def roll(num_dice, die_size)
    (1..num_dice).map { rand(die_size) + 1 }.sum
  end

  def report
    printf(" %2d   %2d   %2d   %2d   %2d   %2d  %4d\n",
           str, int, dex, con, wis, cha, fit)
  end

  def self.done?(population, _generations)
    # they're sorted by descending fitness, so we only need to check the first
    population.first.fitness >= 1021
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
    population.sort_by(&:fitness).reverse.take(2)
  end

  def self.combine(breeders)
    p1,p2 = breeders
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
