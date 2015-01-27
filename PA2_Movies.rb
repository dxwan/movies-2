#Movies Problem Set 1
#David Wan

require 'csv'

class Moviedata
	def initialize(user, movie, scorein)
		@userid = user.to_i
		@movieid = movie.to_i
		@score = scorein.to_i
	end

	def print()
		puts "User: #{@userid}, Movie: #{@movieid}, Score: #{@score}"
	end
	attr_reader :userid, :movieid, :score
end

class TestData
	def initialize(user, movie, score, pscore)
		@userid = user
		@movieid = movie
		@score = score
		@pscore = pscore
	end
	attr_reader :userid, :movieid, :score, :pscore
end

class MovieTest
	def initialize(testdataarray)
		@data = testdataarray
	end
	attr_reader :data
	
	def mean()
		totalerror=0
		numpred=0
		@data.each do |data|
			totalerror += (data.score - data.pscore).abs
			numpred += 1
		end
		avgerror = (totalerror.to_f/numpred.to_f)
		return avgerror
	end
	
	def stddev()
		meanerror = mean()
		totalsquare = 0.0
		totalnum = 0.0
		@data.each do |data|
			totalsquare += (data.pscore - meanerror) * (data.pscore - meanerror)
			totalnum += 1.0
		end
		std = Math.sqrt(totalsquare.to_f/totalnum.to_f)
		return std
	end
	
	def rms()
		totalsquare = 0.0
		totalnum = 0.0
		@data.each do |data|
			totalsquare += (data.score - data.pscore) * (data.score-data.pscore)
			totalnum += 1
		end
		rms = Math.sqrt(totalsquare.to_f/totalnum.to_f)
		return rms
	end 
	
	def to_a()
		return @data
	end
end

#for problem 2
class MovieData
	def initialize(fname)
		@moviearray = getinput(fname)
		@testarray = nil
	end
	def initialize(dataname, testname)
		@moviearray = getinput(dataname)
		@testarray = getinput(testname)
	end
	
	attr_reader :moviearray
	attr_reader :testarray
	
	def rating(user, movie)
		userrating = 0
		@moviearray.each do |data|
			if user==data.userid && data.movieid == movie
				userrating = data.score
			end
		end
		return userrating
	end
	
	def predict(user, movie)
		mean = 0.0
		totalscore = 0.0
		totaluser = 0.0
		
		mostsimlist = most_similar(user, @moviearray)
		mostsimlist.each do |simuser, similarity|
			userrating = rating(simuser, movie).to_f
			if userrating!=0.0
				totalscore+=userrating
				totaluser+=1.0
			end
		end
		mean = totalscore/totaluser
		return mean
	end
	
	def movies(user)
		watched=Array.new
		@moviearray.each do |data|
			if data.userid==user
				watched.push(data.movieid)
			end
		end
		return watched
	end
	
	def viewers(movie)
		viewers={}
		@moviearray.each do |data|
			if data.movieid==movie
				viewers.push(data.userid)
			end
		end
		return viewers
	end
	
	def run_test(k)
		testdata=Array.new
		
		if k==nil
			@testarray.each do |user, movie, score|
				prediction = predict(user, movie)
				testdata.push(TestData.new(user, movie, score, prediction))
			end
		movietestobject = MovieTest.new(testdata)
		return movietestobject
		end
		
		(0..k).each do |i|
			user = @testarray[i].userid
			movie = @testarray[i].movieid
			score = @testarray[i].score
			prediction = predict(user, movie)
			
			testdata.push(TestData.new(user, movie, score, prediction))
		end
		testdata.each do |data|
			puts "creation : #{data.userid}, #{data.movieid}, #{data.score}, #{data.pscore}"
		end
		movietestobject = MovieTest.new(testdata)
		return movietestobject
		
	end
end


def getinput(fname)
	moviearray = Array.new
	CSV.foreach(fname, col_sep: "\t") do |row|
	userid, movieid, score, time = row
	movie = Moviedata.new(userid, movieid, score)
	moviearray.push(movie)
	end
	return moviearray
end

def popularity(movieid, moviearray)
	popularityindex = 0
	moviearray.each do|movie|
		if movieid == movie.movieid
			popularityindex+=1
		end
	end
	return popularityindex
end

def popularity_list(moviearray)
	pophash = {}
	moviearray.each do|movie|
		currentid = movie.movieid
		if !pophash.has_key?(currentid)
			popindex = popularity(currentid, moviearray)
			pophash[currentid] = popindex
		end
	end
	sorted = Hash[pophash.sort_by{|k, v| v}.reverse]
	return sorted
end

def similarity(userone, usertwo, moviearray)
	similarityindex = 0
	userone_hash = {}
	usertwo_hash = {}
	moviearray.each do |movie|
		currentuser = movie.userid
		if currentuser==userone
			userone_hash[movie.movieid] = movie.score
		end
		if currentuser==usertwo
			usertwo_hash[movie.movieid] = movie.score
		end
	end
	userone_hash.each do |movie, score|
		if usertwo_hash.has_key?(movie)
			similarityindex+=1
			if usertwo[movie]==score
				similarityindex+=1
			end
		end
	end
	return similarityindex
end


def most_similar(user, moviearray)
	similarhash = {}
	moviearray.each do |movie|
		currentuser = movie.userid
		if !similarhash.has_key?(currentuser)
			similarityindex = similarity(user, currentuser, moviearray)
			similarhash[currentuser] = similarityindex
		end
	end
	sorted = Hash[similarhash.sort_by{|k, v| v}.reverse]
	shortenedhash = {}
	(1..10).each do |i|
		key = sorted.keys[i]
		value = sorted.values[i]
		shortenedhash[key] = value
	end
	return shortenedhash 
end


filename = "/Users/davidwan/Dropbox/cosi166b_davidwan/movies-2/u1.base"
testname = "/Users/davidwan/Dropbox/cosi166b_davidwan/movies-2/u1.test"
data = MovieData.new(filename, testname)

#moviearray = getinput(filename)

#pop = popularity(421, moviearray)
#puts "#{pop}"
#poplist = popularity_list(moviearray)
#poplist.each do |movie, popularity|
#	puts "Movie: #{movie}, Popularity: #{popularity}"
#end

#similarityindex = similarity(193, 400, moviearray)
#puts "#{similarityindex}"
#mostsimlist = most_similar(193, moviearray)
#mostsimlist.each do |user, simindex|
#	puts "User: #{user}, Similarity: #{simindex}"
#end

#prediction = data.predict(193, 25)
#puts "Prediction: #{prediction}"
#real = data.rating(193, 25)
#puts "Real Score: #{real}"
#movieswatched = data.movies(193)
#puts movieswatched



testobject = data.run_test(10)


std = testobject.stddev()
rms = testobject.rms()
puts "STD: #{std}"
puts "RMS: #{rms}"