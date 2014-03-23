part of BeerSherpa;

int MAX_RESULTS = 40; //Limit search to x results (note: we only consider beers and breweries from the first x results -- therefore this number does not guarentee x hits)

void initSearch(){
  //Init listener for advice button
  querySelector("#advice-button-submit")..onClick.listen((MouseEvent e) => advice());
  //Same for tasts textfield
  querySelector("#tastes-button-submit")..onClick.listen((MouseEvent e) => tastes());
}

void Search(String query){
  //Create url
  String url = "http://beersherpaapp.appspot.com/api?endpoint=search&q=$query&withBreweries=Y&withIngredients=Y";
  //Send request
  var request = HttpRequest.getString(url).then(showResults);
}

void SearchBeer(String query){
  //Create url 
  String url = "http://beersherpaapp.appspot.com/api?endpoint=search&q=$query&type=beer&withBreweries=Y&withIngredients=Y";
  //Send request
  var request = HttpRequest.getString(url).then(showResults);
}

/*
 * Go through all results and build HTML
 */
void showResults(String responseText) {
  
  String jsonString = responseText;

  //Decode the response
  Map parsedMap = JSON.decode(jsonString);
  
  //Get the Total Number of Results from header
  int totalResults = parsedMap["totalResults"];

  //If no results, display the label and thats it
  if(totalResults == null){
  
    HeadingElement h1 = new HeadingElement.h1();
    SpanElement noresultsfound = new SpanElement()..className="label label-warning"..text="No results found.";
    
    h1.append(noresultsfound);
    
    querySelector("#scroll-results").append(h1);

  } else { //We have results, so do things with them
    
    //Limit to MAX_RESULTS results
    if(totalResults > MAX_RESULTS){
      totalResults = MAX_RESULTS;
    }
    
    //Get just the data
    List dataList = parsedMap["data"];
    Map singleResult; //declare
    UListElement newul = new UListElement()..className="list-unstyled"; //declare
    
    //build html for each result
    for(int i = 0; i < totalResults; i++){
      
      singleResult = dataList[i]; //Get the map of data from the list
      
      //Only consider beers and breweries from MAX_RESULTS number of results
      if(singleResult["type"] == "beer"){
        //set image of beer (labels{})
        Map images = singleResult["labels"];
        addResult(singleResult, newul, images);   
      } else if (singleResult["type"] == "brewery"){
        //set image of brewery (images{})
        Map images = singleResult["images"];        
        addResult(singleResult, newul, images); //catch body to add img to         
      }
        
      
    } //end for
    
    //Add the UL to the search result modal
    querySelector("#searchResults").querySelector("#scroll-results").append(newul);
    

  } //end else
  
}

/*
 * Add result as a list item to the UL
 * returns the panelBody for image placement
 */
void addResult(Map singleResult, UListElement ul, Map images){
  
  LIElement newli = new LIElement()..setAttribute("data-dismiss", "modal")..onClick.listen((MouseEvent e) => selectedResult(singleResult));
  DivElement row = new DivElement()..className="row";
  DivElement col4 = new DivElement()..className="col-sm-4";
  DivElement col8 = new DivElement()..className="col-sm-8"..text="${singleResult["description"]}";
  DivElement panel = new DivElement()..className="panel panel-default";
  DivElement panelHeading = new DivElement()..className="panel-heading";
  DivElement panelBody = new DivElement()..className="panel-body";
  HeadingElement panelTitle = new HeadingElement.h3()..className="panel-title"..text="${singleResult["name"]}  ";

  //Get brewery name
  List listd = singleResult["breweries"];
  
  if (listd != null){
    Map brewery = listd[0];
    SpanElement brewspan = new SpanElement()..className="text-muted small"..text="${brewery["name"]}";
    panelTitle.append(brewspan);
  }
  
  panelBody.append(row);
  row.append(col4);
  row.append(col8);
  
  String iconURL;
  if(images != null){
    iconURL = images["medium"];
  }
  
  //Create img and add it if needed
  if(iconURL != "null"){
    ImageElement icon = new ImageElement(src: iconURL);
    icon.className="img-responsive img-rounded";
    col4.append(icon);
  } else {
    col4.text = "[ no picture ]";
  }
  
  if(col8.text == "null"){
    panelBody.text = "[ no description ]";
  }
  

  
  panelHeading.append(panelTitle);
  panel.append(panelHeading);
  panel.append(panelBody);
  
  newli.append(panel);
  
  ul.append(newli);
  
}

/*
 * Create/edit the beer info card html
 */
void createBeerInfoCard(DivElement card, Map singleResult){  
    
    //Set Title
     card.querySelector(".beer-title").text = singleResult["name"];
     List listd = singleResult["breweries"];
    if (listd != null){
      Map brewery = listd[0];
      SpanElement brewspan = new SpanElement()..className="text-muted"..text="  --  ${brewery["name"]}";
      card.querySelector(".beer-title").append(brewspan);
    }
    
    
    //Set Description
    if(singleResult["description"] == null){
      card.querySelector(".beer-desc").text = "[ no description ]";
    } else {
      card.querySelector(".beer-desc").text = singleResult["description"];
    }
    
   
    //Create img and add it if can
    Map images = singleResult["labels"];
    if(images == null){
      //try images
      images = singleResult["images"];
    }
    String iconURL;
    if(images != null){
      iconURL = images["medium"];
    }
    if(iconURL != null){
      ImageElement icon = new ImageElement(src: iconURL);
      icon.className="img-responsive img-rounded";
      card.querySelector(".beer-img").append(icon);
    } else {
      card.querySelector(".beer-img").text = "[ no picture ]";
    }
    
    
    print(singleResult.toString());
    //Set ibu and abv
    if(singleResult["abv"] != null){
      card.querySelector(".beer-abv").classes.remove("hidden");
      card.querySelector(".beer-abv").text = singleResult["abv"] + " ABV";
    }
    
    if(singleResult["ibu"] != null){
      card.querySelector(".beer-ibu").classes.remove("hidden");
      card.querySelector(".beer-ibu").text = singleResult["ibu"] + " IBU";
      
    }
    
    
    
    //Set button listens
    card.querySelector(".beer-yum")..onClick.listen((MouseEvent e)
    {
    	currentUser.like(singleResult, true);
    	fadeCard(querySelector("#advice-beer-card"));
    });
    card.querySelector(".beer-yuk")..onClick.listen((MouseEvent e)
	{
		currentUser.like(singleResult, false);
		fadeCard(querySelector("#advice-beer-card"));
	});
    
    card.classes.remove("hidden");
}

void fadeCard(Element card)
{
	card.classes.add("fade");
	new Timer.periodic(new Duration(seconds:1), (Timer timer)
	{
		timer.cancel();
		card.classes.remove("fade");
		card.classes.add("hidden");
	});
}


/*
 * 
 * LISTENER CALLBACKS:
 * 
 */
void selectedResult(Map singleResult){
  
  if(!querySelector("#advice-page").classes.contains("hidden")){ //if the advice page is not hidden, we will assume we are seeking advice
  
    querySelector("#advice-beer-card").classes.remove("hidden");
    querySelector("#results-jumbotron").classes.remove("hidden");
    DivElement card = querySelector("#advice-beer-card");   
    createBeerInfoCard(card, singleResult);
    
    double similarity = getDistance(getBeerVector(singleResult),currentUser.getVector());
    
    //format the styling
    
  } else { //the advice page is hidden, we will assume we are seeking likes
    
    querySelector("#tastes-beer-card").classes.remove("hidden");
    DivElement card = querySelector("#tastes-beer-card");   
    createBeerInfoCard(card, singleResult);
    
  }
  
  
}

void advice(){ //cant implement keyboard listener until we figure out how to triggle a data-toggle for the modal
  querySelector("#scroll-results").children.clear();
  querySelector("#advice-beer-card").classes.add("hidden");
  querySelector("#results-jumbotron").classes.add("hidden");
  querySelectorAll(".beer-img").forEach((Element e) => e.text=""); 
  querySelectorAll(".beer-desc").forEach((Element e) => e.text=""); 
  querySelectorAll(".beer-label").forEach((Element e) => e.text=""); 
  SearchBeer((querySelector("#advice-input-beer") as InputElement).value);
}

void tastes(){
  querySelector("#scroll-results").children.clear();
  querySelector("#tastes-beer-card").classes.add("hidden");
  querySelectorAll(".beer-img").forEach((Element e) => e.text=""); 
  querySelectorAll(".beer-desc").forEach((Element e) => e.text="");
  querySelectorAll(".beer-label").forEach((Element e) => e.text=""); 
  Search((querySelector("#tastes-input-beer") as InputElement).value);
}





