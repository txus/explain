class Person
  def walk(distance)
    @distance += distance
    @hunger += 2
  end

  def eat(food)
    @hunger -= food.nutritional_value
  end
end