class PeopleController < ApplicationController
  def index
    @people = [Person.first] # TODO
  end
end
