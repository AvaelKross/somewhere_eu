class SearchController < ApplicationController

  def search
    @locations = TripSearch::Provider::StudentAgency.locations
    @search = TripSearch::Search.new
    @results = []
    if params[:search]
      @search = TripSearch::Search.new(search_params)
      @search.date = @search.date.gsub("-", "")
      @results = TripSearch::Provider::StudentAgency.find(@search)
    end
  end

  private

    def search_params
      params.require(:search).permit(:from, :date, :passengers, :max_price, :hide_full)
    end

end