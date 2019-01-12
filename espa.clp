/*
* Author: Nakul Bajaj
* Created: November 24th, 2018
* Function: To guide users in filing their own patents.
*/

; Clear and reset to make environment empty, and then run

(clear)
(reset)

; Create a variable for a new line that can be used as part of a string

(defglobal ?*newLine* = "
")

; Create a variable for a paragraph break for space between lines

(defglobal ?*paragraphBreak* = (str-cat ?*newLine* ?*newLine*))

; Create a variable for a custom section seperator

(defglobal ?*sectionBreak* = (str-cat ?*newLine* "---------------------------------------------------------" ?*newLine*))

; Create a variable for the list of steps that need to be followed – comes with initial directions

(defglobal ?*steps* = (create$ "Download form AIA/14 by visiting https://www.uspto.gov/sites/default/files/documents/aia0014.pdf and open the file in Adobe Acrobat. Unless explicitly mentioned, instructions will apply to fields in this form." "Set the number of inventors, and fill out the legal name, residence information, and mailing address information for each inventor." "In the application information section, fill out the title of your invention, which should be less than 500 characters."))

; Create a variable for tracking the number of questions asked for signposting

(defglobal ?*question-number* = 1)

; All functions needed to ask questions for user interfacing

/*
 * A function to prompt the user with a direction or question
 * Parameters include the variable that will serve as the prompt
 * Returns the response
 */

(deffunction ask (?prompt)
   (printout t ?*question-number* ". " ?prompt crlf crlf)
   (bind ?response (read))
   (printout t ?*newLine*)
   (return ?response)
)

/*
 * A function to prompt the user with a yes or no question
 * Parameters include the variable that will serve as the prompt
 * Returns the response
 */

(deffunction ask-binary (?prompt)
   
   ; Prompts user for answer – asks again if response unreadable
   
   (bind ?response "initial")
   (while (not (or (= ?response "y") (= ?response "n")))
      (bind ?response (lowcase (sub-string 1 1 (ask (str-cat ?prompt ?*newLine* ?*newLine* "(Enter y for yes, n for no)" ?*newLine*)))))
      (if (not (or (= ?response "y") (= ?response "n"))) then
         (printout t "That wasn't a valid response - please format your answer correctly." crlf crlf)
      )
   )
   
   (bind ?*question-number* (+ ?*question-number* 1))
   
   ; Matches response with appropriate return statement
   
   (if (= ?response "y") then
      (bind ?choice yes)
   else (= ?response "n") then
      (bind ?choice no)
   )
   
   (return ?choice)
)

/*
 * A function to prompt the user with a multiple choice question
 * Parameters include a list for the options for answers and the prompt
 * Returns the response
 */

(deffunction ask-multiple-choice (?options ?prompt)
   
   ; Prompts user for answer – asks again if response unreadable
   
   (bind ?answer "")
   (while (not (and (integerp ?answer) (and (<= (integer ?answer) (length$ ?options)) (> (integer ?answer) 0))))
      do
      (bind ?answer (ask (str-cat ?prompt ?*newLine* (print-list ?options))))
      (if (not (and (integerp ?answer) (and (<= (integer ?answer) (length$ ?options)) (> (integer ?answer) 0)))) then
         (printout t "That wasn't a valid response - please format your answer correctly." crlf crlf)
      )
   )
   
   ; Returns the response based on the numerical answer
   
   (bind ?*question-number* (+ ?*question-number* 1))
   (return (nth$ ?answer ?options))
)

/*
 * A function to form a list as a set of options with numerical signposting
 * Parameters include a list for the items that need to be displayed
 * Returns the entire list as a string
 */

(deffunction print-list (?items)
   (bind ?print-list "")
   (for (bind ?index 1) (<= ?index (length$ ?items)) (++ ?index)
      (bind ?print-list (str-cat ?print-list ?*newLine* ?index ". " (nth$ ?index ?items)))
   )
   (return ?print-list)
)

/*
 * A function to form a list as a set of options with numerical signposting with space between each option
 * Parameters include a list for the items that need to be displayed
 * Returns the entire list as a string
 */

(deffunction print-list-with-breaks (?items)
   (bind ?print-list "")
   (for (bind ?index 1) (<= ?index (length$ ?items)) (++ ?index)
      (bind ?print-list (str-cat ?print-list ?*newLine* ?*newLine* ?index ". " (nth$ ?index ?items)))
   )
   (return ?print-list)
)

/*
 * A function to add an item to the end of a list
 * Parameters include a list to be modified and the item to be added
 * Returns the entire list including the new item
 */

(deffunction add$ (?item ?list)
   (bind ?new-list (insert$ ?list (+ (length$ ?list) 1) ?item))
   (return ?new-list)
)

/*
 * A function to add an item to the steps list
 * Parameters include the step to be added to the global steps variable
 */

(deffunction add-step (?step)
   (bind ?*steps* (add$ (str-cat ?step ".") ?*steps*))
)

; Rule base begins here

; All rules to validate the need of a patent

(defrule start-program "Immediately starts the process of guiding the user"
   =>
   (printout t ?*newLine* "Hello and welcome to ESPA, or the Expert System for Patent Applications.")
   (assert (system start))
)

(defrule ask-patent-appropriate "Asks the user if he or she really knows that a patent is appropriate for his/her original idea"
   (system start)
   =>
   (printout t ?*sectionBreak*)
   (assert (patent-sure
   (ask-binary "First and foremost, are you sure that your idea or invention is eligible for patenting?"
      ?*paragraphBreak* "If not, ESPA will help you confirm if that is the best option.")
   ))
)

(defrule confirm-patent-is-appropriate "Checks if the user is trying to patent anything that should not be filed as a patent"
   (patent-sure no)
   =>
   (printout t ?*sectionBreak*)
   (assert (patent-inappropriate (ask-binary
   (str-cat "Is your patent idea in any of the following categories?" ?*newLine*
   (print-list (create$ "Discovery or scientific theory" "Asthetic creation or design" "Scheme or business plan" "Presentation information or methods" "Medical procedure" "Literature such as a slogan, logo, work, text, etc."))
   ))))
)

(defrule patent-is-deemed-appropriate "Checks if a patent idea is actually patentable, and if so, confirms as a fact"
   (patent-inappropriate no)
   =>
   (assert (patent-sure yes))
)

(defrule patent-existence "Checks if a patent idea already exists"
   (patent-sure yes)
   =>
   (printout t ?*sectionBreak*)
   (assert (patent-exists (ask-binary (str-cat
      "Please visit https://www.patents.google.com or https://www.uspto.gov/patents-application-process/search-patents." ?*paragraphBreak*
      "Then, conduct a patent search to see if your patent already exists." ?*paragraphBreak*
      "Does your patent already exist?"
   ))))
)

; Choosing between a provisional and non-provisional patent

(defrule patent-choice "Asks user to pick between non-provisional and provisional patent"
   (patent-exists no)
   =>
   (printout t ?*sectionBreak*)
   (assert (finished-product (ask-binary
      "Have you finished desigining all parts of your invention, are sure of all functional details, and own sufficient evidence showing that you have made significant process in creating your invention?"
   )))
)

(defrule provisional-implied "If not a finished product, then provisional patent is the way to go"
   (finished-product no)
   =>
   (assert (provisional yes))
   (assert (non-provisional no))
   (printout t (str-cat ?*sectionBreak*
      "I have determined that you should apply for a provisional patent as of now." ?*paragraphBreak*
      "This will set the priority date for your patent, so you may file for a non-provisional patent within one year." ?*sectionBreak*
   ))
)

(defrule fill-provisional-info "Adds steps necessary if a provisional application"
   (provisional yes)
   =>
   (add-step "Select the 'Provisional' option for the Application Type field")
   (add-step "If you are including drawing sheets, please include the number of sheets in the field under Application Information.
      Drawing sheets are not necessary for provisional applications like yours")
   (add-step "Fill out form SB0016 from https://www.uspto.gov/sites/default/files/documents/sb0016.pdf")
)

(defrule non-provisional-implied "If a finished product, then non-provisional patent is the way to go"
   (finished-product yes)
   =>
   (assert (provisional no))
   (assert (non-provisional yes))
   (printout t (str-cat ?*sectionBreak* "I have determined that you should apply for a non-provisional patent."))
)

(defrule fill-non-provisional-info "Fills in information if it is a non-provisional application"
   (non-provisional yes)
   =>
   (add-step "Select the 'Non-Provisional' option for the Application Type field")
   (add-step "Include the number of drawing sheets in the field under Application Information.")
)

; Transmit forms

(defrule filing-online "Asks if user is filing online"
   (patent-exists no)
   =>
   (printout t ?*sectionBreak*)
   (assert (online-filing (ask-binary "Will you be filing your patent online via EFS-Web?")))
)

(defrule transmit-form-online "Adds step for online filing"
   (online-filing yes)
   =>
   (add-step "Download form SB0092 from https://www.uspto.gov/sites/default/files/documents/sb0092.pdf and check the box for EFS-Web filing.")
)

(defrule transmit-form-mail "Adds step for mail-in application"
   (online-filing no)
   =>
   (add-step "Download form SB0092 from https://www.uspto.gov/sites/default/files/documents/sb0092.pdf and check the box for depositing via USPS.")
)

; Gathering data for the ADS

(defrule application-data-sheet-begin "Starts the process of gathering data for the ADS"
   (or (online-filing yes) (online-filing no))
   (or (provisional yes) (provisional no))
   =>
   (assert (gather-info preliminary))
)

(defrule secrecy-order "Asks user if they are patenting as part of a government entity"
   (gather-info preliminary)
   =>
   (printout t ?*sectionBreak*)
   (assert (secret-mandate (ask-binary
      "Have you been notified by a government official that your patent is of the nature that it must remain private for the benefit of national security?"
   )))
)

(defrule secrecy-checkbox "Adds step to checkoff secrecy mandate"
   (secret-mandate yes)
   =>
   (add-step "Check the box for Secrecy Order 37 CFR 5.2")
)

; Check if a patent attorney is helping the applicant, or if previous progress has been made

(defrule previous-correspondence "Asks user if they have talked to the USPTO before"
   (gather-info preliminary)
   =>
   (printout t ?*sectionBreak*)
   (assert (customer-number (ask-binary
      "Have you been in contact with, or contacted by the USPTO about this specific potential patent filing previously?"
   )))
)

(defrule fill-customer-number "Adds step to enter customer number"
   (customer-number yes)
   =>
   (add-step "Fill out the field for your Customer Number and email address")
)

(defrule fill-correspondence-address "Adds step to fill in correspondence address"
   (customer-number no)
   =>
   (add-step "Check the box for supplying an address for correspondence, and fill out a mailing address for USPTO communication")
)

; Calculating entity type for fee structure

(defrule npo "Asks user if they are an NPO"
   (gather-info preliminary)
   (not (or (small-entity no) (small-entity yes)))
   =>
   (printout t ?*sectionBreak*)
   (assert (npo (ask-binary "Do you represent a non-profit organization?")))
)

(defrule employees "Asks user if they have less than 500 employees"
   (gather-info preliminary)
   (not (or (small-entity no) (small-entity yes)))
   =>
   (printout t ?*sectionBreak*)
   (assert (less-employees (ask-binary "Does the entity that is filing the patent have less than 500 employees in total, including affiliates?")))
)

(defrule small-business-concern "Confirms patent is for small entity use only"
   (or (less-employees yes) (npo yes))
   =>
   (printout t ?*sectionBreak*)
   (assert (large-entity-contact (ask-binary "Will you be assigning, licensing, or showing interest in this patent to an entity which is not a non-profit organization and has more than 500 employees?")))
)

(defrule not-small-entity "Uses current information to identify that applicant cannot file as small entity"
   (or (large-entity-contact yes) (and (less-employees no) (npo no)))
   =>
   (assert (small-entity no))
)

(defrule qualifies-small-entity "Checks if applicant qualifies for small entity status"
   (and (or (less-employees yes) (npo yes)) (large-entity-contact no))
   =>
   (assert (small-entity yes))
)

(defrule previous-patents-ask "Asks user if they have filed for patents before"
   (small-entity yes)
   (not (micro-entity yes))
   (not (micro-entity no))
   =>
   (printout t ?*sectionBreak*)
   (assert (previous-patents (ask-binary
      "Have you been listed as an inventor on any 4 previous patent applications, foreign or domestic, provisional or non-provisional?"
   )))
)

(defrule gross-income-ask "Asks user if they are earning more than gross-income threshold"
   (small-entity yes)
   (not (micro-entity yes))
   (not (micro-entity no))
   =>
   (printout t ?*sectionBreak*)
   (assert (gross-income (ask-binary "Do you currently earn more than $184,116 per year?")))
)

(defrule micro-licensing-ask "Checks if micro-licensing will work for showing interest to other corporations"
   (small-entity yes)
   (not (micro-entity yes))
   (not (micro-entity no))
   =>
   (printout t ?*sectionBreak*)
   (assert (micro-licensing (ask-binary (str-cat
      "Do you plan to, or have you, shown interest in assigning or licensing your patent to another entity that either..."
      (print-list (create$
         "Earns more than $184,116 per year without status as an institution for higher education" "OR" "Is not an NPO and employs more than 500 workers"
      ))
   ))))
)

(defrule micro-entity-status-confirmed "Confirms that micro-entity status is possible"
   (small-entity yes)
   (previous-patents no)
   (gross-income no)
   (micro-licensing no)
   =>
   (assert (micro-entity yes))
)

(defrule micro-entity-by-higher-ed "Micro-entity affirmed with higher education"
   (micro-entity yes)
   =>
   (printout t ?*sectionBreak*)
   (assert (employed-by-ed (ask-binary "Are you employed by an institution of higher education which is legally established as a non-profit?")))
)

(defrule confirm-ed-employed "Asserts that gross-income is not the reason for micro-entity status"
   (employed-by-ed yes)
   =>
   (assert (low-gross-income no))
)

(defrule confirm-low-income "Low gross income is confirmed since education is not the reason"
   (employed-by-ed no)
   =>
   (assert (low-gross-income yes))
)

(defrule micro-entity-status-violated "Applicant does not have micro-entity status"
   (small-entity yes)
   (or (previous-patents yes) (gross-income yes) (micro-licensing yes))
   =>
   (assert (micro-entity no))
)

(defrule fill-entity-size "Adds step for claiming small-entity status"
   (small-entity yes)
   =>
   (add-step "Check the box for claiming small entity status")
)

(defrule fill-micro-entity-form-education "Fills in extra form for micro entity if dependent on education"
   (employed-by-ed yes)
   =>
   (add-step "Fill form SB0015B, and include it with your application. Visit https://www.uspto.gov/sites/default/files/forms/sb0015b.pdf to download")
)

(defrule fill-micro-entity-form-income "Fills in extra form for micro entity if dependent on income"
   (low-gross-income yes)
   =>
   (add-step "Fill form SB0015A, and include it with your application. Visit https://www.uspto.gov/sites/default/files/forms/sb0015a.pdf to download")
)

; Asks user for type of patent

(defrule subject-matter "Asks user what is the subject matter of their patent"
   (gather-info preliminary)
   =>
   (printout t ?*sectionBreak*)
   (assert-string (str-cat "(subject-matter " (lowcase (ask-multiple-choice (create$ "Utility" "Design" "Plant")
      "Please enter the number that corresponds with the type of invention you are trying to patent."
   )) ")"))
)

(defrule fill-subject-matter-utility "Adds steps for utility patent"
   (subject-matter utility)
   =>
   (add-step "Choose the 'Utility' option in the Subject Matter field")
   (add-step "Fill out form AIA0001 and include it with your application. Download at https://www.uspto.gov/sites/default/files/documents/aia0001.pdf")
)

(defrule subject-matter-utility-transmit "Adds steps for non-provisional utility patent"
   (subject-matter utility)
   (non-provisional yes)
   =>
   (add-step "Fill out form AIA0015 and include it with your application. Download at https://www.uspto.gov/sites/default/files/documents/aia0015.pdf")
)

(defrule fill-subject-matter-design "Adds steps for design patent"
   (subject-matter design)
   =>
   (add-step "Choose the 'Design' option in the Subject Matter field")
   (add-step "Fill out form AIA0001 and include it with your application. Download at https://www.uspto.gov/sites/default/files/documents/aia0001.pdf")
)

(defrule subject-matter-design-transmit "Adds steps for non-provisional design patent"
   (subject-matter design)
   (non-provisional yes)
   =>
   (add-step "Fill out form AIA0018 and include it with your application. Download at https://www.uspto.gov/sites/default/files/documents/aia0018.pdf")
)

(defrule fill-subject-matter-plant "Adds steps for plant patent"
   (subject-matter plant)
   =>
   (add-step "Choose the 'Plant' option in the Subject Matter field")
   (add-step "Fill out form AIA0003 and include it with your application. Download at https://www.uspto.gov/sites/default/files/forms/aia0003.pdf")
)

(defrule subject-matter-plant-transmit  "Adds steps for non-provisional plant patent"
   (subject-matter plant)
   (non-provisional yes)
   =>
   (add-step "Fill out form AIA0019 and include it with your application. Download at https://www.uspto.gov/sites/default/files/documents/aia0019.pdf")
)

; Check if a patent needs to be expedited

(defrule expedited-ask "Asks users if patent should be expedited"
   (non-provisional yes)
   =>
   (printout t ?*sectionBreak*)
   (assert (expedited (ask-binary "Would you like to submit your patent so that it is expedited for review?")))
)

(defrule fill-expedited-design "If need expedited status, then fill out forms for design patent faster process"
   (expedited yes)
   (subject-matter design)
   =>
   (add-step "Fill out form SB0027 and include it with your application. It can be downloaded at https://www.uspto.gov/sites/default/files/documents/sb0027.pdf")
)

(defrule fill-expedited-plant-and-utility "If need expedited status, then fill out forms for plant/utility patent faster process"
   (expedited yes)
   (or (subject-matter utility) (subject-matter plant))
   =>
   (add-step "Fill out form AIA0424 and include it with your application. It can be downloaded at https://www.uspto.gov/sites/default/files/forms/aia0424.pdf. Check box 3.I")
)

(defrule foreign-publication "Asks user if they would like to publish their patent in a foreign country"
   (foreign-access no)
   =>
   (printout t ?*sectionBreak*)
   (assert (foreign-publication (ask-binary "Do you plan to ever file a patent for your invention in any other nation, including as part of a WIPO agreement?")))
)

(defrule ask-no-publication "Asks user if they would like to avoid publication"
   (foreign-publication no)
   =>
   (printout t ?*sectionBreak*)
   (assert (publication (ask-binary (str-cat "Would you like to publish your patent for public availability?" ?*paragraphBreak* "If you choose not to, your patent will still hold legal value, but will be hidden from public viewing."))))
)

(defrule fill-avoid-publication "Adds steps for requesting not to publish"
   (publication no)
   =>
   (add-step "Check the box for requesting not to publish as part of the Publication Information section and fill out form SB0035 from https://www.uspto.gov/sites/default/files/web/forms/sb0035.pdf")
)

(defrule ask-early-publication "Asks user if they would like early publication"
   (publication yes)
   =>
   (printout t ?*sectionBreak*)
   (assert (early-publication (ask-binary
      "Would you like to request early publication of your patent, so it will be published 3-4 weeks after approval instead of 18 months?"
   )))
)

(defrule fill-early-publication "Adds step for early publication"
   (early-publication yes)
   =>
   (add-step "Check the box for requesting early publication as part of the Publication Information section")
)

(defrule legal-representative "Asks user if they will be represented by a certified patent practitioner"
   (gather-info preliminary)
   =>
   (printout t ?*sectionBreak*)
   (assert (legal-representative (ask-binary "In filing this patent application, will you be represented by a certified US patent practitioner?")))
)

(defrule customer-number-representation "Uses known information to find out proper representation type"
   (legal-representative no)
   (customer-number yes)
   =>
   (assert (customer-number-representation yes))
)

(defrule personal-representative "Uses known information to find out proper representation type"
   (legal-representative no)
   (customer-number no)
   =>
   (assert (self-representation yes))
)

(defrule customer-number-rep "Uses known information to find out proper representation type"
   (customer-number-representation yes)
   =>
   (add-step "Check the box for entering a Customer Number in the Representative Information section, and fill out the field for the customer number")
)

(defrule personal-rep "Uses known information to find out proper representation type"
   (self-representation yes)
   =>
   (add-step "Check the box for Limited Recognition in the Representative Information section, and fill out the fields with your legal name")
)

(defrule legal-rep "Uses known information to find out proper representation type"
   (legal-representative yes)
   =>
   (add-step "Check the box for US Patent Practitioner in the Representative Information section, and fill out the fields with your attorney's legal name and his or her registration number")
)

(defrule foreign-priority-ask "Asks user if they have filed for this patent before in another country or as part of a patent agreement"
   (gather-info preliminary)
   =>
   (printout t ?*sectionBreak*)
   (assert (foreign-priority (ask-binary "Have you filed a patent for this invention in another country or as part of an international patent agreement before?")))
)

(defrule foreign-priority-fill "Adds step for adding foreign priority information"
   (foreign-priority yes)
   =>
   (add-step "Fill out all fields in the Foreign Priority Information section")
)

(defrule foreign-access-ask "Asks if foreign access should be allowed"
   (gather-info preliminary)
   =>
   (printout t ?*sectionBreak*)
   (assert (foreign-access (ask-binary (str-cat "Would you like to allow foreign intellectual property offices associated with the US to have access to your application as it is filed?" ?*paragraphBreak* "Answering yes is recommended."))))
)

(defrule foreign-access-fill "Adds steps for foreign access"
   (foreign-access no)
   =>
   (add-step "Check box 2.A. in the Authorization for Permit Access section")
)

(defrule epo-access-ask "Asks if EPO access should be allowed"
   (gather-info preliminary)
   =>
   (printout t ?*sectionBreak*)
   (assert (epo-access (ask-binary (str-cat "Would you like to allow the European Patent Office to have access to your application as it is filed?" ?*paragraphBreak* "Answering yes is recommended."))))
)

(defrule epo-access-fill "Adds steps for EPO access"
   (epo-access no)
   =>
   (add-step "Check box 2.B. in the Authorization for Permit Access section")
)

(defrule payment-method-ask "Asks what payment method should be used"
   (gather-info preliminary)
   =>
   (printout t ?*sectionBreak*)
   (assert-string (lowcase (str-cat "(payment-method " (ask-multiple-choice (create$ "Check" "Credit Card" "Money Order" "Deposit Account") "Enter the number that corresponds with your payment method for USPTO fees.") ")")))
)

(defrule payment-fill-all "Adds steps for payment methods"
   (or (payment-method check) (payment-method credit card) (payment-method money order) (payment-method deposit account))
   =>
   (add-step "Fill out form SB0017 from https://www.uspto.gov/sites/default/files/documents/sb0017.pdf and check off your method of payment. Download worksheet SB0006 to calculate fee structure, https://www.uspto.gov/sites/default/files/documents/sb0006.pdf")
)

(defrule payment-fill-card "Adds steps for card payment method"
   (payment-method credit card)
   =>
   (add-step "Fill out form PTO-2038 from https://www.uspto.gov/sites/default/files/documents/PTO-2038.pdf and enter your credit card information")
)

(defrule explicit-applicant-ask "Confirms that inventor is the applicant"
   (gather-info preliminary)
   =>
   (printout t ?*sectionBreak*)
   (assert (explicit-applicant (ask-binary "As the applicant, are you also the inventor of the creation that is being patented?")))
)

(defrule applicant-info "If not, adds step for adding additional applicants"
   (explicit-applicant no)
   =>
   (add-step "Fill out the Application Information section with the applicant's information. Add as many applicant blocks as needed")
)

(defrule violation-occured "Checks if patent idea is actually patentable, and if not, interrupts the program"
   (or (patent-inappropriate yes) (patent-exists yes))
   =>
   (printout t ?*sectionBreak*)
   (printout t "Sorry, under our current legal code, you will not be able to patent your idea." ?*paragraphBreak* "If your idea is a slogan, logo, or work of literature, try to obtain a certified copyright or trademark." ?*sectionBreak*)
   (halt)
)

(defrule fill-assignee-info "Default step to include all assignees in the patent application"
   (gather-info preliminary)
   =>
   (add-step
      "Fill out the Assignee Information section with information for those who should be listed on the published application. Add as many assignee blocks as needed"
   )
)

(defrule no-more-questions "No more questions can be asked – time to tell the user what to do"
   (declare (salience -100))
   =>
   (add-step "Fill out all sections of the claims worksheet, which can be found here: https://bit.ly/2RmRS03")
   (printout t ?*sectionBreak* "Thank you for answering all questions. Please follow the steps below to file your patent." ?*sectionBreak*)
   (printout t (print-list-with-breaks ?*steps*) crlf crlf)
)

(run)
