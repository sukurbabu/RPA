*** Settings ***
Documentation     Orders robots from RobotSpareBin Industries Inc.
...               Saves the order HTML receipt as a PDF file.
...               Saves the screenshot of the ordered robot.
...               Embeds the screenshot of the robot to the PDF receipt.
...               Creates ZIP archive of the receipts and the images.
Library           RPA.Browser.Selenium
Library           RPA.HTTP
Library           RPA.Excel.Files
Library           RPA.PDF
Library           RPA.Tables



# +
*** Keywords ***
Open website
    Open Available Browser      https://robotsparebinindustries.com/#/
    Maximize Browser Window

*** Keywords ***
Login into Robotsparebin
    Input Text    username      maria
    Input Password    password      thoushallnotpass
    Submit Form
    Wait Until Element Is Visible    firstname

# -

*** Keywords ***
Close the annoying modal
    Click Element    //a[@class='nav-link']
    Click Button     //button[text()='OK']

*** Keywords ***
Navigate to Home
    Click Element    //a[text()='Home']

*** Keywords ***
Open the robot order website
    Open website
    Login into Robotsparebin


*** Keywords ***
Download Orders CSV
    Download    https://robotsparebinindustries.com/orders.csv    overwrite=True

*** Keywords ***
Get Orders
    ${Orders}=  Read Table From Csv    orders.csv   header=true  
    [Return]    ${Orders}

*** Keywords ***
Fill And Submit The Form For One Order
    [Arguments]    ${head}      ${body}     ${legs}     ${address}
    ${body}=    Convert To Integer      ${body} 
    
    IF      ${body} == 1
    ${body_text}    Set Variable    Roll-a-thor body
    ELSE IF     ${body} == 2 
    ${body_text}     Set Variable   Peanut crusher body
    ELSE IF     ${body} == 3 
    ${body_text}     Set Variable   D.A.V.E body
    ELSE IF     ${body} == 4 
    ${body_text}     Set Variable   Andy Roid body
    ELSE IF     ${body} == 5 
    ${body_text}     Set Variable   Spanner mate body
    ELSE IF     ${body} == 6 
    ${body_text}     Set Variable   Drillbit 2000 body
    END
    Select From List By Value       head        ${head}
    Click Element     //label[text()='${body_text}']//input   
    Input Text    //input[@placeholder='Enter the part number for the legs']    ${legs}
    Input Text    address    ${address}
    Click Button    preview
    Click Button    order

***Keywords***
Store the receipt as a PDF file
    [Arguments]    ${order_id}
    ${sales_results_html}=    Get Element Attribute    //div[@id='receipt']/h3    text
    log     ${sales_results_html}
    ${PDF_File}     Set Variable    ${CURDIR}${/}output${/}receipts${/}Orders ${order_id}.pdf
    Html To Pdf    ${sales_results_html}    ${PDF_File} 
    [return]    ${PDF_File}

***Keywords***
Take a screenshot of the robot
    [Arguments]    ${order_id}
    ${File_name}    Set Variable    ${CURDIR}${/}output${/}screenshots${/}order_${order_id}.png
    Capture Element Screenshot      robot-preview-image     ${File_name}
    [Return]    ${File_name}

***Keywords***
Embed the robot screenshot to the receipt PDF file
    [Arguments]    ${screenshot}    ${pdf}
    #@{screenshot}   Convert To List     ${screenshot}
    ${f}    Create List     ${screenshot}
    log     @{f}
    Open Pdf    ${pdf}
    Add Files To Pdf    ${f}   ${pdf}

*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Open the robot order website
    Download Orders CSV
    ${Orders}=      Get Orders
    FOR    ${row}    IN    @{Orders}
        Close the annoying modal
        log     ${row}
        Fill And Submit The Form For One Order      ${row}[Head]    ${row}[Body]    ${row}[Legs]    ${row}[Address]
        ${pdf}=    Store the receipt as a PDF file    ${row}[Order number]
        ${screenshot}=    Take a screenshot of the robot    ${row}[Order number]
        Embed the robot screenshot to the receipt PDF file    ${screenshot}    ${pdf}
        log     ${pdf}
        Navigate to Home
    END


