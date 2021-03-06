module TaskMapper::Provider
  module Teambox
    # Ticket class for taskmapper-teambox
    API = TeamboxAPI::Task # The class to access the api's tickets
    
    class Ticket < TaskMapper::Provider::Base::Ticket
      # declare needed overloaded methods here
      
      def initialize(*object)
        if object.first
          args = object
          object = args.shift
          project_id = args.shift
          @system_data = {:client => object}
          unless object.is_a? Hash
           hash = {:status => object.status,
                   :name => object.name,
                   :updated_at => object.updated_at,
                   :id => object.id,
                   :project_id => project_id.nil? ? object.prefix_options[:project_id] : project_id}
          else
            hash = object
          end
          super hash
        end
      end

      def self.create(*options)
        task = API.new(options.first.merge!(:status => 1,
                                            :updated_at => Time.now
                                            )) 
        ticket = self.new task
        task.save
        ticket
      end

      def self.find_by_id(project_id, task_id)
        self.search(project_id, {:id => task_id}).first
      end

      def self.search(project_id, options = {}, limit = 1000)
        tickets = API.find(:all, :params => {:project_id => project_id}).collect { |ticket| self.new ticket, project_id }
        self.search_by_attribute(tickets, options, limit)
      end

      def self.find_by_attributes(project_id, attributes = {})
        self.search(project_id, attributes)
      end

      def project_id
        self[:project_id]
      end

      def task_id
        self[:id]
      end

      def comment!(*options)
        options[0].update(:project_id => project_id, :task_id => task_id) if options.first.is_a?(Hash)
        provider_parent(self.class)::Comment.create(*options)
      end
      

    end
  end
end
