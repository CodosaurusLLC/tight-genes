class TruckLoad
    class Item
      attr_reader :name, :weight, :value
      def initialize(name, weight, value)
        @name   = name
        @weight = weight
        @value  = value
      end
    end

    ITEMS = [
      Item.new("Cow",       1500,  2000),
      Item.new("Milk",      1720,   800),
      Item.new("Cheese",    1000, 12000),
      Item.new("Butter",    1000,  3000),
      Item.new("Ice Cream", 1000,  2000),
      Item.new("Meat",      1280,  8000),
      Item.new("Leather",   1100,  6000),
    ]

  def self.initial_population(how_many)
    population = []
    for i in 1..how_many
      population.append(self.new)
    end
    return population
  end  

  def self.run
    pop = TruckLoad.initial_population(10)
    while ! TruckLoad.done?(pop) do
      breeders = TruckLoad.select_breeders(pop)
      pop = TruckLoad.new_population(breeders.first, breeders.last, 10)
      pop.each { |p| p.maybe_mutate }
    end
    pop
  end

  attr_reader :contents, :fitness
  def initialize(val=nil)
    @contents = val || rand(128)
  end

  def to_h
    ITEMS.
      map.
      with_index { |item, index|
        [ item.name, contents & (1 << index) == 0 ? "N" : "Y"]
      }.
      to_h.
      merge({"Fitness" => fitness})
  end

  def to_s
    to_h.
      values.
      map { |v| "<td>#{v}</td>" }.
      join.
      gsub(/<td>(\d*)<\/td>$/, '<td class="numeric">\1</td>').
      gsub(/^/, '<tr>').
      gsub(/$/, '</tr>')
  end

  def fitness()
    return @fitness if @fitness
    weight =
      (0 ... ITEMS.count).
      map { |n| ((1 << n) & @contents) > 0 ? ITEMS[n].weight : 0 }.
      sum
    return (@fitness = 0) if weight > 4000
    @fitness =
      (0 ... ITEMS.count).
      map { |n| ((1 << n) & @contents) > 0 ? ITEMS[n].value : 0 }.
      sum
  end

  @@best_combo  = self.new(0)
  @@generations = 0

  def self.done?(population)
    @@generations += 1
    candidates =
      population.
      select { |c| c.fitness > @@best_combo.fitness }
    return @@generations >= 100 if candidates.none?
    @@best_combo = candidates.sort_by(&:fitness).last
    @@generations = 0
    false
  end

  def self.select_breeders(population)
    population.
      sort_by(&:fitness).
      reverse.
      take(2)
  end
  
  def self.breed(p1, p2)
    cross_point = rand(ITEMS.count + 1)
    list =
      (0..ITEMS.count).
      map { |index|
        parent = index < cross_point ? p1 : p2
        parent.contents & (1 << index)
      }.
      sum
    return self.new(list)
  end

  def self.new_population(p1, p2, how_many)
    population = []
    for i in 1..how_many
      population.append(self.breed(p1,p2))
    end
    return population
  end

  def maybe_mutate()
    (0..ITEMS.count).
      each { |index|
        if rand(3) == 0
          @contents ^= 1 << index
        end
      }
  end  
end
