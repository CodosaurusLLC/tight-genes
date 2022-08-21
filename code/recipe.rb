class Recipe
  REPORT_HEADER = "Ratio  Tolerance  %ABV  Sweet     Fit"
  attr_accessor :ratio, :tolerance, :abv, :sweet, :fit

  def initialize()
    # water-to-honey ratio of 1.5 to 15
    @ratio = roll(3, 10) / 2.0
    # alcohol tolerance of 6-20
    @tolerance = 4 + roll(2, 8)
  end

  def roll(num_dice, die_size)
    (1..num_dice).map { rand(die_size) + 1 }.sum
  end

  def report
    printf("%5.2f       %4.1f  %4.1f   %4.1f  %6.1f\n",
           ratio, tolerance, abv, sweet, fit)
  end

  def self.done?(population, _generations)
    # they're sorted by descending fitness, so we only need to check the first
    population.first.fitness >= 99.9
  end

  def fitness()
    return fit if fit  # may be already cached
    # target_abv = 12   # about typical wine
    # target_sweet = 15 # semi-dry
    # target_abv = 7    # session - low-ish alcohol
    # target_sweet = 5  # session - dry
    target_abv = 18     # sack/great - high alcohol
    target_sweet = 35   # sack/great - very sweet
    @abv, @sweet = evaluate()
    abv_off = (target_abv - abv).abs
    sweet_off = (target_sweet - sweet).abs
    off = abv_off ** 2 + sweet_off ** 2
    @fit = 100 - off;
  end

  def evaluate()
    # use 1 liter water (mass 1kg), and the appropriate amount of honey
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
    population.sort_by(&:fitness).reverse.take(2)
  end

  def self.combine(breeders)
    p1,p2 = breeders
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

