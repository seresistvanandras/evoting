package main

import (


	"github.com/parnurzeal/gorequest"

	"net/http"
	"html/template"
	"log"

	"fmt"
	"regexp"
)

type RadioButton struct {
	Name       string
	Value      string
	Text       string
	Action     string
}

type PageVariables struct {
	PageTitle        string
	PageRadioButtons []RadioButton
	Answer           string
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

	http.HandleFunc("/", DisplayRadioButtons)
	http.HandleFunc("/selected", UserSelected)
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

func DisplayRadioButtons(w http.ResponseWriter, r *http.Request){
	// Display some radio buttons to the user

	Title := "E-voting API test"
	MyRadioButtons := []RadioButton{
		RadioButton{"select", "1", "Get eligible voters", "/selected"},
		RadioButton{"select", "2", "Get blinded Votes",  "/selected"},
		RadioButton{"select", "3", "Get votes",  "/selected"},
		RadioButton{"select", "4", "Remove Eligible voter", "/selected"},
		RadioButton{"select", "5", "Add eligible voter",  "/selected"},
		RadioButton{"select", "6", "Cast a vote",  "/selected"},
		RadioButton{"select", "7", "Ask authority to blindly sign", "/selected"},
		RadioButton{"select", "8", "Write blind signature",  "/selected"},
		RadioButton{"select", "9", "Verify Blind Signature",  "/selected"},
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

func UserSelected(w http.ResponseWriter, r *http.Request){

	a := regexp.MustCompile("=")
	splitted := a.Split(r.URL.RawQuery, -1)

	base_url := "http://localhost:8000"

	castVote := `{"choiceCode": "1", "vote": "1","hashVote":"80084422859880547211683076133703299733277748156566366325829078699459944778998",
		"blindlySignedVote": "12"}`

	blindedVote := `{"blindedVote": "1"}`

	blindedVotesWrite:= `{"voter": "0x90f8bf6a479f320ead074411a4b0e7944ea8c9c1", "blindSig": "1"}`

	blindedVotesVerify := `{"vote": "80084422859880547211683076133703299733277748156566366325829078699459944778998", "blindlySignedVote": "12"}`

	Title := "E-voting API test"
	MyPageVariables := PageVariables{
		PageTitle: Title,
	}

	// generate page by passing page variables into template
	t, err := template.ParseFiles("/home/jani/Documents/Projects/evoting/src/go/index.html") //parse the html file homepage.html
	if err != nil { // if there is an error
		log.Print("template parsing error: ", err) // log it
	}

	err = t.Execute(w, MyPageVariables) //execute the template and pass it the HomePageVars struct to fill in the gaps
	if err != nil { // if there is an error
		log.Print("template executing error: ", err) //log it
	}

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



}
