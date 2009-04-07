class Admin::System::ConfigurationsController < Admin::SystemController
  # GET /configurations
  # GET /configurations.xml
  
  Configuration = Opensteam::Config::Base
  def index
    @configurations = Configuration.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @configurations }
    end
  end

  # GET /configurations/1
  # GET /configurations/1.xml
  def show
    @configuration = Configuration.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @configuration }
    end
  end

  # GET /configurations/new
  # GET /configurations/new.xml
  def new
    @configuration = Configuration.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @configuration }
    end
  end

  # GET /configurations/1/edit
  def edit
    @configuration = Configuration.find(params[:id])
  end

  # POST /configurations
  # POST /configurations.xml
  def create
    @configuration = Configuration.new(params[:configuration])

    respond_to do |format|
      if @configuration.save
        flash[:notice] = 'Configuration was successfully created.'
        format.html { redirect_to( admin_system_configuration_path( @configuration) ) }
        format.xml  { render :xml => @configuration, :status => :created, :location => @configuration }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @configuration.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /configurations/1
  # PUT /configurations/1.xml
  def update
    @configuration = Configuration.find(params[:id])

    respond_to do |format|
      if @configuration.update_attributes(params[:configuration])
        flash[:notice] = 'Configuration was successfully updated.'
        format.html { redirect_to(admin_system_configuration_path( @configuration)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @configuration.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /configurations/1
  # DELETE /configurations/1.xml
  def destroy
    @configuration = Configuration.find(params[:id])
    @configuration.destroy

    respond_to do |format|
      format.html { redirect_to(admin_system_configurations_url) }
      format.xml  { head :ok }
    end
  end
end
