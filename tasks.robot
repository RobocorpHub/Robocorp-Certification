*** Settings ***
Documentation       Orders robots from RobotSpareBin Industries Inc.
...                 Saves the order HTML receipt as a PDF file.
...                 Saves the screenshot of the ordered robot.
...                 Embeds the screenshot of the robot to the PDF receipt.
...                 Creates ZIP archive of the receipts and the images.

Library             RPA.Browser.Selenium    auto_close=${False}
Library             RPA.Excel.Files
Library             RPA.PDF
Library             RPA.Desktop
Library             RPA.Tables
# Library    RPA.FTP
Library             RPA.Archive
Library             RPA.HTTP
Library             RPA.FileSystem


*** Tasks ***
Orders robots from RobotSpareBin Industries Inc
    Downlaod orders and submit
    Ready with the data
    Closing Formalities


*** Keywords ***
Downlaod orders and submit
    Download    https://robotsparebinindustries.com/orders.csv    overwrite=True
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order

Ready with the data
    ${orders}=    Read table from CSV    orders.csv    header=${True}
    FOR    ${order}    IN    @{orders}
        Log    ${order}
        Open robot order website    ${order}
    END

Open robot order website
    [Arguments]    ${order}
    Click Button    OK
    Sleep    1
    Select From List By Index    head    ${order}[Head]
    Select Radio Button    body    ${order}[Body]
    Input Text    //input[contains(@class,'form-control')][contains(@type,'number')]    ${order}[Legs]
    Input Text    address    ${order}[Address]
    Sleep    1
    Click Button    Preview
    Screenshot    id:robot-preview-image    ${OUTPUT_DIR}${/}${order}[Order number].png
    Click Button    order
    ${error}=    Does Page Contain Element    //div[contains(@class, "lert alert-danger")]
    WHILE    ${error}
        Sleep    1
        Click Button    order
        ${error}=    Does Page Contain Element    //div[contains(@class, "lert alert-danger")]
    END

    ${order_results_html}=    Get Element Attribute    id:receipt    outerHTML
    ${pdf_path}=    Set Variable    ${OUTPUT_DIR}${/}${order}[Order number].pdf
    Log    ${pdf_path}
    Html To Pdf    ${order_results_html}    ${pdf_path}
    Log    ${pdf_path}

    ${robot_img}=    Create List    ${OUTPUT_DIR}${/}${order}[Order number].png
    Add Files To Pdf    ${robot_img}    ${pdf_path}    True
    Wait Until Page Contains Element    id:order-another
    Click Button    order-another

Closing Formalities
    Archive Folder With Zip    ${OUTPUT_DIR}    ${OUTPUT_DIR}${/}report.Zip    include=*.pdf
    ${files}=    Find Files    ${OUTPUT_DIR}${/}*.pdf
    FOR    ${file}    IN    @{files}
        Remove File    ${file}
    END
    ${files}=    Find Files    ${OUTPUT_DIR}${/}*.png
    FOR    ${file}    IN    @{files}
        Remove File    ${file}
    END
    Close Browser

Minimal task
    Log    Done.
