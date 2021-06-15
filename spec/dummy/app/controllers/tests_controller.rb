class TestsController < ApplicationController
  def index
    @tests = Test.all
    @test = Test.new
  end

  def new
    @test = Test.new
  end

  def create
    @test = Test.new(test_params)
    @test.save ? redirect_to(tests_path) : render(:new)
  end

  def edit
    @test = Test.find(params[:id])
  end

  def update
    @test = Test.find(params[:id])
    @test.update(test_params)
  end

  private

  def test_params
    params.require(:test).permit(abyme_attributes, :title, :description)
  end
end