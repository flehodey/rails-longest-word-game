require 'open-uri'
require 'json'
class LongestController < ApplicationController

def game
  # TODO: generate random grid of letters
  @grid = []

  params[:query].to_i.times do
    @grid << ("A".."Z").to_a.sample
    @start_time = Time.now
  end
  @grid
end

def score_method(attempt, time_difference)
 @score = ((attempt.length * 20) - time_difference)
 return @score
end


def matches_grid?(attempt, grid)
  grid = params[:grid].split("")
 attempt_characters_array = attempt.upcase.chars
 @check = []
 attempt_characters_array.each do |character|
   grid.include?(character) ? @check << true && grid.delete_at(grid.find_index(character)) : @check << false
 end
 if @check.include?(false)
   return false
 else
   return true
 end
end


def translation?(attempt)
 api_doc = JSON.parse(open("http://api.wordreference.com/0.8/80143/json/enfr/#{attempt}").read)
 if api_doc["Error"] == "NoTranslation"
   return false
 else
   @translated_word = api_doc["term0"]["PrincipalTranslations"]["0"]["FirstTranslation"]["term"]
   return @translated_word
 end
end



def score
 grid = params[:grid].split("")
 attempt = params[:word]
 @start_time = Time.parse(params[:start_time])
 @end_time = Time.now
 time_difference = (@end_time - @start_time)
 translation = translation?(attempt)
 if matches_grid?(attempt, grid)
   if translation != false
     points = score_method(attempt, time_difference)
     message = "well done"
   else
     message = "not an english word"
     translation = nil
     points = 0
   end
 else
   message = "not in the grid"
   translation = nil
   points = 0
 end
 @result = { time: time_difference, translation: translation, score: points, message: message }
end

end
