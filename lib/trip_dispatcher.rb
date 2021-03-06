require 'csv'
require 'time'

require_relative 'driver'
require_relative 'passenger'
require_relative 'trip'
#require_relative 'time'

module RideShare
  class TripDispatcher
    attr_reader :drivers, :passengers, :trips

    def initialize
      @drivers = load_drivers
      @passengers = load_passengers
      @trips = load_trips

    end

    # this is what i was trying to create but this not make sense because this is a method
    # def time
    #   @start_time = start_time
    #   @end_time = end_time
    # end
#initialize that raises an ArgumentError if the end time is before the start time, and a corresponding test
    def load_drivers
      my_file = CSV.open('support/drivers.csv', headers: true)

      all_drivers = []
      my_file.each do |line|
        input_data = {}
        # Set to a default value
        vin = line[2].length == 17 ? line[2] : "0" * 17

        # Status logic
        status = line[3]
        status = status.to_sym

        input_data[:vin] = vin
        input_data[:id] = line[0].to_i
        input_data[:name] = line[1]
        input_data[:status] = status
        all_drivers << Driver.new(input_data)
      end

      return all_drivers
    end

    def find_driver(id)
      check_id(id)
      @drivers.find{ |driver| driver.id == id }
    end

    def load_passengers
      passengers = []

      CSV.read('support/passengers.csv', headers: true).each do |line|
        input_data = {}
        input_data[:id] = line[0].to_i
        input_data[:name] = line[1]
        input_data[:phone] = line[2]

        passengers << Passenger.new(input_data)
      end

      return passengers
    end

    def find_passenger(id)
      check_id(id)
      @passengers.find{ |passenger| passenger.id == id }
      end

      #Ask Charles tomorrow what this does exaclty does.

    def request_trip(passenger_id)

      available_driver = @drivers.find{|driver| driver.status == :Available }
      if available_driver == nil
        return nil
      end

      passenger = find_passenger(passenger_id)
      if passenger == nil
        return nil
      end

      requested_trip = {
        id: @trips.length + 1,
        driver: driver,
        passenger: passenger,
        start_time: Time.now, #current-time- what is current-time?
        end_time: nil,
        cost: nil,
        rating: nil
      }

        trip = Trip.new(requested_trip)
        available_driver.add_trip(trip)
        passenger.add_trip(trip)
        @trips.push(trip)
        return trip


    end


    def load_trips
      trips = []
      trip_data = CSV.open('support/trips.csv', 'r', headers: true, header_converters: :symbol)

      trip_data.each do |raw_trip|
        driver = find_driver(raw_trip[:driver_id].to_i)
        passenger = find_passenger(raw_trip[:passenger_id].to_i)

        parsed_trip = {
          id: raw_trip[:id].to_i,
          driver: driver,
          passenger: passenger,
          start_time: raw_trip[:start_time],
          end_time: raw_trip[:end_time],
          cost: raw_trip[:cost].to_f,
          rating: raw_trip[:rating].to_i
        }


        parsed_trip[:end_time] = Time.parse(parsed_trip[:end_time])
        parsed_trip[:start_time] = Time.parse(parsed_trip[:start_time])




        trip = Trip.new(parsed_trip)
        # this is what i changed
        # start_time = Time.new(parsed_end_time)[:start_time]
        # end_time = Time.new(parsed_end_time)[:end_time]
        driver.add_trip(trip)
        passenger.add_trip(trip)
        trips << trip
      end

      trips
    end

    private




     # this checks id if the id does not exist or the id is less than or equal to zero.
    def check_id(id)
      if id == nil || id <= 0
        raise ArgumentError.new("ID cannot be blank or less than zero. (got #{id})")
      end
    end
  end
end
