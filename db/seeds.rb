Project.destroy_all

project_types = ["Residential", "Office", "Commercial"]
10.times do |i|
  
  title         = "%s %s" % [RandomWord.nouns.next.capitalize, RandomWord.adjs.next]
  client        = Faker::Internet.email
  project_type  = project_types[Random.rand(0..2)]
  
  input_h = {
    title: title,
    client: client,
    project_type: project_type
  }

  Project.create(input_h)
end
