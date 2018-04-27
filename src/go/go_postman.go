package main

import (


	"github.com/parnurzeal/gorequest"

	"net/http"
	"html/template"
	"log"

	"fmt"

	"path/filepath"
	"os"
	"regexp"
	"encoding/json"

	"net/url"
	"path"
)

type Question struct {
	Question string `json:"question"`
}

type RadioButton struct {
	Name       string
	Value      string
	Text       string
	Action     string
	Class	   string
}

type PageVariables struct {
	PageTitle        string
	PageQuestion	 string
	PageRadioButtons []RadioButton
	Answer           string
}

type Vote struct {
	ChoiceCode  string
	C			string
	S 			string
}

type TxResponse struct {
	TransactionHash   string      `json:"transactionHash"`
	TransactionIndex  int         `json:"transactionIndex"`
	BlockHash         string      `json:"blockHash"`
	BlockNumber       int         `json:"blockNumber"`
	GasUsed           int         `json:"gasUsed"`
	CumulativeGasUsed int         `json:"cumulativeGasUsed"`
	ContractAddress   interface{} `json:"contractAddress"`
	Status            string      `json:"status"`
	LogsBloom         string      `json:"logsBloom"`
	Events            struct {
		VoteSuccess struct {
			LogIndex         int    `json:"logIndex"`
			TransactionIndex int    `json:"transactionIndex"`
			TransactionHash  string `json:"transactionHash"`
			BlockHash        string `json:"blockHash"`
			BlockNumber      int    `json:"blockNumber"`
			Address          string `json:"address"`
			Type             string `json:"type"`
			ID               string `json:"id"`
			ReturnValues     struct {
				Num0       string `json:"0"`
				Num1       string `json:"1"`
				Voter      string `json:"voter"`
				ChoiceCode string `json:"choiceCode"`
			} `json:"returnValues"`
			Event     string `json:"event"`
			Signature string `json:"signature"`
			Raw       struct {
				Data   string   `json:"data"`
				Topics []string `json:"topics"`
			} `json:"raw"`
		} `json:"voteSuccess"`
	} `json:"events"`
}

type votesStruct struct {
	Votes string `json:"votes"`
}

func main() {
/*
	base_url := "http://localhost:8000"

	castVote := `{"choiceCode": "1", "vote": "1","hashVote":"80084422859880547211683076133703299733277748156566366325829078699459944778998",
		"blindlySignedVote": "12"}`

	blindedVote := `{"blindedVote": "1"}`

	blindedVotesWrite:= `{"voter": "0x90f8bf6a479f320ead074411a4b0e7944ea8c9c1", "blindSig": "1"}`

	blindedVotesVerify := `{"vote": "80084422859880547211683076133703299733277748156566366325829078699459944778998", "blindlySignedVote": "12"}`

	// get eligibleVoters mapping
	fmt.Println(reqGet(base_url+"/vote/0x90f8bf6a479f320ead074411a4b0e7944ea8c9c1"))

	// get blindedVotes mapping
	fmt.Println(reqGet(base_url+"/bvotes/1"))

	// get votes mapping
	fmt.Println(reqGet(base_url+"/votes/1"))

	// removeEligibleVoter
	fmt.Println(reqDelete(base_url+"/vote/0x90f8bf6a479f320ead074411a4b0e7944ea8c9c1"))

	// addEligibleVoter
	fmt.Println(reqPost(base_url+"/vote/0x90f8bf6a479f320ead074411a4b0e7944ea8c9c1",castVote))

	// cast a vote
	fmt.Println(reqPost(base_url+"/cast/",castVote))

	// requires authority to blindly sign
	fmt.Println(reqPost(base_url+"/bvotes/req",blindedVote))

	// write blindsignature
	fmt.Println(reqPost(base_url+"/bvotes/write",blindedVotesWrite))

	// verify blindlySignedVote
	fmt.Println(reqPost(base_url+"/bvotes/verify",blindedVotesVerify))

	fmt.Println("ALL FINISHED!")
*/
	dir, err := filepath.Abs(filepath.Dir(os.Args[0]))
	if err != nil {
		log.Fatal(err)
	}

	http.HandleFunc("/", indexFunc)
	http.HandleFunc("/admin", adminSelected)
	http.HandleFunc("/voter", voterSelected)
	http.HandleFunc("/selected", voteSelected)

	http.HandleFunc("/addVoter", addVoter)
	http.HandleFunc("/getResults", getResults)

	u, err := url.Parse(dir)
	u.Path = path.Join(u.Path, "/css")
	//serve the css library
	http.Handle("/css/", http.StripPrefix("/css/", http.FileServer(http.Dir(u.String()))))

	u, err = url.Parse(dir)
	u.Path = path.Join(u.Path, "/js")
	http.Handle("/js/", http.StripPrefix("/js/", http.FileServer(http.Dir(u.String()))))

	log.Fatal(http.ListenAndServe(":8080", nil))



}

func reqGet(url string) string {
	request := gorequest.New()
	resp, body, err := request.Get(url).End()
	if err != nil && resp.StatusCode != 200{
		panic(err)
	}

	return body
}

func reqPost(url string, c string) string{
	request := gorequest.New()
	resp, body, err := request.Post(url).
		Send(c).
		End()

	if err != nil && resp.StatusCode != 200{
		panic(err)
	}

	return body

}

func reqDelete(url string) string {

	request := gorequest.New()
	resp, body, err := request.Delete(url).End()
	if err != nil && resp.StatusCode != 200{
		panic(err)
	}

	return body
}
/*
func DisplayRadioButtons(w http.ResponseWriter, r *http.Request){
	// Display some radio buttons to the user

	Title := "E-voting API test"
	MyRadioButtons := []RadioButton{
		RadioButton{"select", "1", "Get eligible voters", "/selected", "/selected},
		RadioButton{"select", "2", "Get blinded Votes",  "/selected", "/selected},
		RadioButton{"select", "3", "Get votes",  "/selected", "/selected},
		RadioButton{"select", "4", "Remove Eligible voter", "/selected", "/selected},
		RadioButton{"select", "5", "Add eligible voter",  "/selected", "/selected},
		RadioButton{"select", "6", "Cast a vote",  "/selected", "/selected},
		RadioButton{"select", "7", "Ask authority to blindly sign", "/selected", "/selected},
		RadioButton{"select", "8", "Write blind signature",  "/selected", "/selected},
		RadioButton{"select", "9", "Verify Blind Signature",  "/selected", "/selected},
	}

	MyPageVariables := PageVariables{
		PageTitle: Title,
		PageRadioButtons : MyRadioButtons,
	}

	t, err := template.ParseFiles("/home/jani/Documents/Projects/evoting/src/go/index.html") //parse the html file homepage.html
	if err != nil { // if there is an error
		log.Print("template parsing error: ", err) // log it
	}

	err = t.Execute(w, MyPageVariables) //execute the template and pass it the HomePageVars struct to fill in the gaps
	if err != nil { // if there is an error
		log.Print("template executing error: ", err) //log it
	}

}
*/

func indexFunc(w http.ResponseWriter, r *http.Request){
	// Display some radio buttons to the user

	fmt.Println("Index")

	dir, err := filepath.Abs(filepath.Dir(os.Args[0]))
	if err != nil {
		log.Fatal(err)
	}

	Title := "E-voting API test"
	MyRadioButtons := []RadioButton{
		RadioButton{"select", "1", "Admin", "/admin", "btn btn-primary btn-lg btn-block"},
		RadioButton{"select", "2", "Voter",  "/voter", "btn btn-secondary btn-lg btn-block"},
	}

	MyPageVariables := PageVariables{
		PageTitle: Title,
		PageRadioButtons : MyRadioButtons,
	}



	t, err := template.ParseFiles(dir+"/index.html") //parse the html file homepage.html

	if err != nil { // if there is an error
		log.Print("template parsing error: ", err) // log it
	}

	err = t.Execute(w, MyPageVariables) //execute the template and pass it the HomePageVars struct to fill in the gaps
	if err != nil { // if there is an error
		log.Print("template executing error: ", err) //log it
	}



}

func DisplayRadioButtons(w http.ResponseWriter, r *http.Request){
	// Display some radio buttons to the user

	Title := "E-voting API test"
	MyRadioButtons := []RadioButton{
		RadioButton{"select", "1", "Get eligible voters", "/selected", "/selected"},
		RadioButton{"select", "2", "Get blinded Votes",  "/selected", "/selected"},
		RadioButton{"select", "3", "Get votes",  "/selected", "/selected"},
		RadioButton{"select", "4", "Remove Eligible voter", "/selected", "/selected"},
		RadioButton{"select", "5", "Add eligible voter",  "/selected", "/selected"},
		RadioButton{"select", "6", "Cast a vote",  "/selected", "/selected"},
		RadioButton{"select", "7", "Ask authority to blindly sign", "/selected", "/selected"},
		RadioButton{"select", "8", "Write blind signature",  "/selected", "/selected"},
		RadioButton{"select", "9", "Verify Blind Signature",  "/selected", "/selected"},
	}

	MyPageVariables := PageVariables{
		PageTitle: Title,
		PageRadioButtons : MyRadioButtons,
	}


	dir, err := filepath.Abs(filepath.Dir(os.Args[0]))
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println(dir)

	t, err := template.ParseFiles(dir+"admin.html") //parse the html file homepage.html

	if err != nil { // if there is an error
		log.Print("template parsing error: ", err) // log it
	}

	err = t.Execute(w, MyPageVariables) //execute the template and pass it the HomePageVars struct to fill in the gaps
	if err != nil { // if there is an error
		log.Print("template executing error: ", err) //log it
	}

}

func voterSelected(w http.ResponseWriter, r *http.Request){

	fmt.Println("voter")

	base_url := "http://localhost:8001"

	question := Question{}
	if err := json.Unmarshal([]byte(getQuestion(base_url)), &question); err != nil {
		return
	}



	castVote := `{"choiceCode": "1", "vote": "1","hashVote":"80084422859880547211683076133703299733277748156566366325829078699459944778998",
		"blindlySignedVote": "12"}`

	blindedVote := `{"blindedVote": "1"}`

	blindedVotesWrite:= `{"voter": "0x90f8bf6a479f320ead074411a4b0e7944ea8c9c1", "blindSig": "1"}`

	blindedVotesVerify := `{"vote": "80084422859880547211683076133703299733277748156566366325829078699459944778998", "blindlySignedVote": "12"}`

	Title := "Voting Form"

	MyRadioButtons := []RadioButton{

		RadioButton{"select", "1", "Get votes",  "/selected", "/selected"},

		RadioButton{"select", "2", "Cast a vote",  "/selected", "/selected"},
		RadioButton{"select", "3", "Ask authority to blindly sign", "/selected", "/selected"},

		RadioButton{"select", "4", "Verify Blind Signature",  "/selected", "/selected"},
	}

	MyPageVariables := PageVariables{
		PageTitle: Title,
		PageQuestion: question.Question,
		PageRadioButtons : MyRadioButtons,

	}



	dir, err := filepath.Abs(filepath.Dir(os.Args[0]))
	if err != nil {
		log.Fatal(err)
	}

	fmt.Println("kakkkkk"+dir)

	t, err := template.ParseFiles(dir+"/voter.html") //parse the html file homepage.html
	if err != nil { // if there is an error
		log.Print("template parsing error: ", err) // log it
	}

	err = t.Execute(w, MyPageVariables) //execute the template and pass it the HomePageVars struct to fill in the gaps
	if err != nil { // if there is an error
		log.Print("template executing error: ", err) //log it
	}



	if r.URL.RawQuery != ""{
		a := regexp.MustCompile("=")
		splitted := a.Split(r.URL.RawQuery, -1)
		switch splitted[1]{
		case "1":
			// get eligibleVoters mapping
			var resp = reqGet(base_url+"/usedsignatures/16654675467547647667567567")
			fmt.Fprintln(w, resp)
		case "2":
			// get blindedVotes mapping
			var resp = reqGet(base_url+"/bvotes/1")
			fmt.Fprintln(w, resp)
		case "3":
			// get votes mapping
			var resp = reqGet(base_url+"/votes/1")
			fmt.Fprintln(w, resp)
		case "4":
			// removeEligibleVoter
			var resp = reqDelete(base_url+"/vote/0x90f8bf6a479f320ead074411a4b0e7944ea8c9c1")
			fmt.Fprintln(w, resp)
		case "5":
			// addEligibleVoter
			var resp = reqPost(base_url+"/vote/0x90f8bf6a479f320ead074411a4b0e7944ea8c9c1",castVote)
			fmt.Fprintln(w, resp)
		case "6":
			// cast a vote
			var resp =reqPost(base_url+"/cast/",castVote)
			fmt.Fprintln(w, resp)
		case "7":
			// requires authority to blindly sign
			var resp = reqPost(base_url+"/bvotes/req",blindedVote)
			fmt.Fprintln(w, resp)
		case "8":
			// write blindsignature
			var resp = reqPost(base_url+"/bvotes/write",blindedVotesWrite)
			fmt.Fprintln(w, resp)
		case "9":
			// verify blindlySignedVote
			var resp = reqPost(base_url+"/bvotes/verify",blindedVotesVerify)
			fmt.Fprintln(w, resp)
		}
	}



}

func adminSelected(w http.ResponseWriter, r *http.Request){

	fmt.Println("admin selected")
/*
	a := regexp.MustCompile("=")
	splitted := a.Split(r.URL.RawQuery, -1)

	base_url := "http://localhost:8000"

	castVote := `{"choiceCode": "1", "vote": "1","hashVote":"80084422859880547211683076133703299733277748156566366325829078699459944778998",
		"blindlySignedVote": "12"}`

	blindedVote := `{"blindedVote": "1"}`

	blindedVotesWrite:= `{"voter": "0x90f8bf6a479f320ead074411a4b0e7944ea8c9c1", "blindSig": "1"}`

	blindedVotesVerify := `{"vote": "80084422859880547211683076133703299733277748156566366325829078699459944778998", "blindlySignedVote": "12"}`
*/
	Title := "E-voting API test"
	MyPageVariables := PageVariables{
		PageTitle: Title,
	}




	dir, err := filepath.Abs(filepath.Dir(os.Args[0]))
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println(dir)

	t, err := template.ParseFiles(dir+"/admin.html") //parse the html file homepage.html
	if err != nil { // if there is an error
		log.Print("template parsing error: ", err) // log it
	}

	err = t.Execute(w, MyPageVariables) //execute the template and pass it the HomePageVars struct to fill in the gaps
	if err != nil { // if there is an error
		log.Print("template executing error: ", err) //log it
	}
/*
	switch splitted[1]{
	case "1":
		// get eligibleVoters mapping
		var resp = reqGet(base_url+"/vote/0x90f8bf6a479f320ead074411a4b0e7944ea8c9c1")
		fmt.Fprintln(w, resp)
	case "2":
		// get blindedVotes mapping
		var resp = reqGet(base_url+"/bvotes/1")
		fmt.Fprintln(w, resp)
	case "3":
		// get votes mapping
		var resp = reqGet(base_url+"/votes/1")
		fmt.Fprintln(w, resp)
	case "4":
		// removeEligibleVoter
		var resp = reqDelete(base_url+"/vote/0x90f8bf6a479f320ead074411a4b0e7944ea8c9c1")
		fmt.Fprintln(w, resp)
	case "5":
		// addEligibleVoter
		var resp = reqPost(base_url+"/vote/0x90f8bf6a479f320ead074411a4b0e7944ea8c9c1",castVote)
		fmt.Fprintln(w, resp)
	case "6":
		// cast a vote
		var resp =reqPost(base_url+"/cast/",castVote)
		fmt.Fprintln(w, resp)
	case "7":
		// requires authority to blindly sign
		var resp = reqPost(base_url+"/bvotes/req",blindedVote)
		fmt.Fprintln(w, resp)
	case "8":
		// write blindsignature
		var resp = reqPost(base_url+"/bvotes/write",blindedVotesWrite)
		fmt.Fprintln(w, resp)
	case "9":
		// verify blindlySignedVote
		var resp = reqPost(base_url+"/bvotes/verify",blindedVotesVerify)
		fmt.Fprintln(w, resp)
	}

*/

}

func voteSelected(w http.ResponseWriter, r *http.Request) {


	fmt.Println("vote")
	a := regexp.MustCompile("=")
	splitted := a.Split(r.URL.RawQuery, -1)

	base_url := "http://localhost:8001"


	Title := "E-voting API test"
	MyPageVariables := PageVariables{
		PageTitle: Title,
	}

	dir, err := filepath.Abs(filepath.Dir(os.Args[0]))
	if err != nil {
		log.Fatal(err)
	}
	// generate page by passing page variables into template
	t, err := template.ParseFiles(dir+"/index.html") //parse the html file homepage.html
	if err != nil { // if there is an error
		log.Print("template parsing error: ", err) // log it
	}

	err = t.Execute(w, MyPageVariables) //execute the template and pass it the HomePageVars struct to fill in the gaps
	if err != nil { // if there is an error
		log.Print("template executing error: ", err) //log it
	}

	votes := &Vote{splitted[1], "36569675563270980802762714306156177901149277261141117320653538205171502807189", "6584969667293602680567734539575163142389903381909774456551685991814241531484"}

	//create json
	b, err := json.Marshal(votes)
	if err != nil {
		fmt.Println(err)
		return
	}


	var resp= reqPost(base_url+"/cast/", string(b))

	txResp := TxResponse{}
	if err := json.Unmarshal([]byte(resp), &txResp); err != nil {
		return
	}



	fmt.Fprintln(w, "https://rinkeby.etherscan.io/tx/"+txResp.TransactionHash)




}

func addVoter(w http.ResponseWriter, r *http.Request) {


	fmt.Println("addVoter")


	base_url := "http://localhost:8001"


	Title := "E-voting API test"
	MyPageVariables := PageVariables{
		PageTitle: Title,
	}

	dir, err := filepath.Abs(filepath.Dir(os.Args[0]))
	if err != nil {
		log.Fatal(err)
	}

	// generate page by passing page variables into template
	t, err := template.ParseFiles(dir+"/index.html") //parse the html file homepage.html
	if err != nil { // if there is an error
		log.Print("template parsing error: ", err) // log it
	}

	err = t.Execute(w, MyPageVariables) //execute the template and pass it the HomePageVars struct to fill in the gaps
	if err != nil { // if there is an error
		log.Print("template executing error: ", err) //log it
	}

	a := regexp.MustCompile("=")
	splitted := a.Split(r.URL.RawQuery, -1)


	var resp= reqPost(base_url+"/voter/"+splitted[1], "")

	txResp := TxResponse{}
	if err := json.Unmarshal([]byte(resp), &txResp); err != nil {
		return
	}

	fmt.Fprintln(w, "https://rinkeby.etherscan.io/tx/"+txResp.TransactionHash)




}

func getResults(w http.ResponseWriter, r *http.Request) {


	fmt.Println("getResults")


	base_url := "http://localhost:8001"


	Title := "E-voting API test"
	MyPageVariables := PageVariables{
		PageTitle: Title,
	}

	dir, err := filepath.Abs(filepath.Dir(os.Args[0]))
	if err != nil {
		log.Fatal(err)
	}

	// generate page by passing page variables into template
	t, err := template.ParseFiles(dir+"/index.html") //parse the html file homepage.html
	if err != nil { // if there is an error
		log.Print("template parsing error: ", err) // log it
	}

	err = t.Execute(w, MyPageVariables) //execute the template and pass it the HomePageVars struct to fill in the gaps
	if err != nil { // if there is an error
		log.Print("template executing error: ", err) //log it
	}


	var resp0= reqGet(base_url+"/votes/0")
	var resp1= reqGet(base_url+"/votes/1")

	txResp0 := votesStruct{}
	if err := json.Unmarshal([]byte(resp0), &txResp0); err != nil {
		return
	}

	txResp1 := votesStruct{}
	if err := json.Unmarshal([]byte(resp1), &txResp1); err != nil {
		return
	}

	fmt.Fprintln(w, txResp0.Votes+","+txResp1.Votes)


}

func getQuestion (base_url string) string{
	return reqGet(base_url+"/question")
}

