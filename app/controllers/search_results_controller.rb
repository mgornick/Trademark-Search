class SearchResultsController < ApplicationController
  # GET /search_results
  # GET /search_results.xml
  def index
    @search_results = SearchResult.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @search_results }
    end
  end

  # GET /search_results/1
  # GET /search_results/1.xml
  def show
    @search_result = SearchResult.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @search_result }
    end
  end

  # GET /search_results/new
  # GET /search_results/new.xml
  def new
    @search_result = SearchResult.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @search_result }
    end
  end

  # GET /search_results/1/edit
  def edit
    @search_result = SearchResult.find(params[:id])
  end

  # POST /search_results
  # POST /search_results.xml
  def create
    @search_result = SearchResult.new(params[:search_result])

    respond_to do |format|
      if @search_result.save
        flash[:notice] = 'SearchResult was successfully created.'
        format.html { redirect_to(@search_result) }
        format.xml  { render :xml => @search_result, :status => :created, :location => @search_result }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @search_result.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /search_results/1
  # PUT /search_results/1.xml
  def update
    @search_result = SearchResult.find(params[:id])

    respond_to do |format|
      if @search_result.update_attributes(params[:search_result])
        flash[:notice] = 'SearchResult was successfully updated.'
        format.html { redirect_to(@search_result) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @search_result.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /search_results/1
  # DELETE /search_results/1.xml
  def destroy
    @search_result = SearchResult.find(params[:id])
    @search_result.destroy

    respond_to do |format|
      format.html { redirect_to(search_results_url) }
      format.xml  { head :ok }
    end
  end
end
