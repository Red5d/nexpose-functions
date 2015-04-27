# Nexpose functions


# Log into a Nexpose console. Returns a connection object.
#
# @param consoleIP [String] the IP address of the Nexpose console.
# @return [Connection] the connection object.
def NexposeLogin(consoleIP)
    require "io/console"

    print "Username: "
    username = $stdin.gets.chomp
    print "Password: "
    password = STDIN.noecho(&:gets).chomp
    puts ""

    # Blank the proxy variables so they won't be used to connect to the Console.
    ENV['http_proxy'] = nil
    ENV['https_proxy'] = nil
    
    # Create connection and login.
    nsc = Nexpose::Connection.new(consoleIP, username, password)
    nsc.login
    return nsc
end

class Nexpose::Connection
    # Check if an input is a valid engine id.
    #
    # @param engID [Fixnum] an id to check against the list of valid engine ids.
    # @return [Boolean] true if engID is valid.
    def validate_engineid(engID)
        # Create array of engine ids for validation
        engine_ids = []
        for eng in self.list_engines do
            engine_ids << eng.id
        end

        return engine_ids.include?(engID.to_i)    
    end

    # Get the ID for a site name.
    #
    # @param sitename [String] the site name to look up.
    # @return [Fixnum] the id for the site name.
    def sitename_to_id(sitename)
        self.list_sites.each { |site|
            if site.name == sitename
                return site.id
            end
        }
    end

    # Get the name for a site ID.
    #
    # @param siteid [Fixnum] a site id to look up.
    # @return [String] the name of the site.
    def siteid_to_name(siteid)
        self.list_sites.each { |site|
            if site.id == siteid
                return site.name
            end
        }
    end

    # Get a Hash object containing pairs of site ids/names where the Hash key is the site id.
    #
    # @return [Hash] object with site ids as the keys and site names as the values.
    def getSitesInfobyId()
        sitesinfo = {}
        self.list_sites.each { |site|
            sitesinfo[site.id] = site.name
        }
        return sitesinfo
    end

    # Get a Hash object containing pairs of site names/ids where the Hash key is the site name.
    #
    # @return [Hash] object with site names as the keys and site ids as the values.
    def getSitesInfobyName()
        sitesinfo = {}
        self.list_sites.each { |site|
            sitesinfo[site.name] = site.id
        }
        return sitesinfo
    end
    
    # Get a Hash object containing pairs of scan template names/ids where the Hash key is the scan template id.
    #
    # @return [Hash] object with scan template ids as the keys and scan template names as the values.
    def getScanTemplatesbyId()
        templateinfo = {}
        self.list_scan_templates.each { |template|
            templateinfo[template.id] = template.name
        }
        return templateinfo
    end
    
    # Get a Hash object containing pairs of scan template names/ids where the Hash key is the scan template name.
    #
    # @return [Hash] object with scan template names as the keys and scan template ids as the values.
    def getScanTemplatesbyName()
        templateinfo = {}
        self.list_scan_templates.each { |template|
            templateinfo[template.name] = template.id
        }
        return templateinfo
    end

    # Get an Asset object for the specified host IP.
    #
    # @param host [String] the hostname to get an Asset object for.
    # @return [Asset] the Asset object for the host.
    def getAsset(host)
        return self.filter(Nexpose::Search::Field::ASSET, Nexpose::Search::Operator::IS, host)
    end

    # Get an array of Asset objects for hosts that have not been scanned in 'X' days.
    #
    # @param days [Fixnum] the number of days back to check for unscanned hosts.
    # @return [Array[Asset]] array of Asset objects for the hosts.
    def notScannedSince(days)
        return self.filter(Nexpose::Search::Field::SCAN_DATE, Nexpose::Search::Operator::EARLIER_THAN, days.to_i)
    end
end

class Nexpose::Site

    # Load asset hostnames from a CSV file.
    #
    # @param nsc [Connection] an active connection to a Nexpose console.
    # @param csvfile [String] path to a CSV file to load hostnames from. (The first column will be used.) 
    def load_csv_hostnames(nsc, csvfile)
        puts "Loading site..."
        @site = Site.load(@nsc, self.id)

        puts "Building hostname/asset list..."
        @hostnames = []
        CSV.foreach(@csvfile) do |line|
            @hostnames << HostName.new(line[0])
        end

        puts "Saving site assets..."
        @site.included_addresses = @hostnames
        @site.save(@nsc)
        puts "Done."
        puts "Site #{self.id} now has #{@hostnames.length} assets."
    end
    
end
