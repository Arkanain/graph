module Graph
  def self.included(base)
    base.extend(ClassMethods)
  end

  def ensure_unique(name)
    begin
      self[name] = yield
    end while self.class.exists?(name: self[name])
  end

  module ClassMethods
    TEST_GRAPH = {
          a: { b: 5, d: 5, e: 7 },
          b: { c: 4 },
          c: { d: 8, e: 2 },
          d: { c: 8, e: 6 },
          e: { b: 3 }
    }

    POSSIBLE_EDGES = TEST_GRAPH.keys.sort.map(&:to_s)

    # This method will help us to add new edge to graph or change distance from one already existed edge to another.
    # Example: add_edge('a', 'c', 4)
    def add_edge(from, to, distance)
      if POSSIBLE_EDGES.include?(from) && POSSIBLE_EDGES.include?(to)
        TEST_GRAPH[from.to_sym][to.to_sym] = distance

        puts "Way from #{from} to #{to} with distance #{distance} is successfully added."
      else
        wrong_edge_error
      end
    end

    # This method give us possibility to check distance from one edge to another
    # Example: distance('a', 'b', 'c')
    def distance(*args)
      if(args - POSSIBLE_EDGES).empty?
        dist = 0
        args.map!(&:to_sym)

        (args.length - 1).times do |a|
          if TEST_GRAPH[args[a]][args[a + 1]].nil?
            return 'No route'
          else
            dist += TEST_GRAPH[args[a]][args[a + 1]]
          end
        end

        puts "Distance of the route #{args.join('-')} is #{dist}."
      else
        wrong_edge_error
      end
    end

    # This method give us possibility to check number of ways from one edge to another with maximum stops between
    # this edges.
    # Example: maximum_stops('c', 'c', 3)
    def maximum_stops(started_at, ended_at, stops_number)
      @possible_ways = 0
      @ended_at = ended_at.to_sym

      if POSSIBLE_EDGES.include?(started_at) && POSSIBLE_EDGES.include?(ended_at)
        with_recursive_stops(started_at.to_sym, stops_number)
        puts "Number of possible ways with maximum stops - #{@possible_ways}."
      else
        wrong_edge_error
      end
    end

    # This method give us possibility to check number of ways from one edge to another with exactly stops between them
    # Example: exactly_stops('a', 'c', 4)
    def exactly_stops(started_at, ended_at, stops_number)
      @possible_ways = 0
      @ended_at = ended_at.to_sym

      if POSSIBLE_EDGES.include?(started_at) && POSSIBLE_EDGES.include?(ended_at)
        exactly_recursive_stops(started_at.to_sym, stops_number)
        puts "Number of possible ways with exactly stops - #{@possible_ways}."
      else
        wrong_edge_error
      end
    end

    # This method show us shortest way from one edge to another.
    # This method implement Dijkstra’s algorithm.
    # Example: shortest_way('a', 'c')
    def shortest_way(started_at, ended_at)
      default_way = 8 ** 20
      @edges_weight = POSSIBLE_EDGES.inject({}) { |sum, key|  sum.merge({ key.to_sym => { way: default_way, prev_edge: nil } }) }

      if POSSIBLE_EDGES.include?(started_at) && POSSIBLE_EDGES.include?(ended_at)
        Hash[TEST_GRAPH[started_at.to_sym]].keys.each do |edge|
          all_edges = POSSIBLE_EDGES.map(&:to_sym)
          min_way(edge, started_at.to_sym, TEST_GRAPH[started_at.to_sym][edge], all_edges)
        end

        min_way = @edges_weight[ended_at.to_sym][:way] == default_way ? 'no route' : @edges_weight[ended_at.to_sym][:way]
        unless min_way.is_a?(String)
          t_edge = @edges_weight[ended_at.to_sym][:prev_edge]
          ended_at << t_edge.to_s

          until t_edge == started_at.to_sym
            ended_at << @edges_weight[t_edge][:prev_edge].to_s
            t_edge = @edges_weight[t_edge][:prev_edge]
          end

          ended_at.reverse!
          puts "Through edges - #{ended_at}."
        end

        puts "Min distance is #{min_way}."
      else
        wrong_edge_error
      end
    end

    # This method show us all uniq possible ways from one edge to another with maximum distance between them.
    # Example: less_than_distance('c', 'c', 30)
    def less_than_distance(started_at, ended_at, max_distance)
      @ended_at = ended_at.to_sym
      @max_distance = max_distance
      @ways_counter = 0
      @all_ways = []
      @current_way = ''

      if POSSIBLE_EDGES.include?(started_at) && POSSIBLE_EDGES.include?(ended_at)
        Hash[TEST_GRAPH[started_at.to_sym]].keys.each do |edge|
          @current_way << started_at
          possible_way(edge, started_at.to_sym, 0)
          @current_way.chop!
        end

        if @ways_counter < 1
          puts "No way from point #{started_at} to point #{ended_at} with distance #{max_distance}"
        else
          puts "Number of possible ways = #{@ways_counter}"
          puts "List of possible ways:"
          @all_ways.each_with_index { |way, index| puts "#{index + 1}. #{way}" }
        end
      else
        wrong_edge_error
      end
    end

    private

    def with_recursive_stops(from, stops)
      if stops > 0
        if TEST_GRAPH[from].keys.include?(@ended_at)
          keys = TEST_GRAPH[from].except(@ended_at).keys
          @possible_ways +=1
        end

        keys ||= TEST_GRAPH[from].keys

        keys.each { |k| with_recursive_stops(k, stops - 1) }
      end
    end

    def exactly_recursive_stops(from, stops)
      if stops > 0
        if TEST_GRAPH[from].keys.include?(@ended_at) && stops == 1
          @possible_ways +=1
        end

        TEST_GRAPH[from].keys.each { |k| exactly_recursive_stops(k, stops - 1) }
      end
    end

    def min_way(current_edge, prev_edge, distance, all_edges)
      if @edges_weight[current_edge][:way] > distance
        @edges_weight[current_edge][:way] = distance
        @edges_weight[current_edge][:prev_edge] = prev_edge
      end

      all_edges -= [current_edge]

      Hash[TEST_GRAPH[current_edge]].keys.each do |edge|
        if all_edges.include?(edge)
          min_way(edge, current_edge, distance + TEST_GRAPH[current_edge][edge], all_edges)
        end
      end
    end

    def possible_way(current_edge, prev_edge,  distance)
      distance += TEST_GRAPH[prev_edge][current_edge]

      if distance < 30
        if current_edge == @ended_at
          unless @all_ways.include?(@current_way + current_edge.to_s)
            @all_ways << @current_way + current_edge.to_s
            @ways_counter += 1
          end
        end

        Hash[TEST_GRAPH[current_edge]].keys.each do |edge|
          @current_way << current_edge.to_s
          possible_way(edge, current_edge, distance)
          @current_way.chop!
        end
      end
    end

    def wrong_edge_error
      puts "You enter wrong edge in params. Edge should be character from this array #{POSSIBLE_EDGES}"
    end
  end
end

class ActiveRecord::Base
  include Graph
end