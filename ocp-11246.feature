Feature: secret subcommand - generic
# @author weinliu@redhat.com
# @case_id OCP-11246
Scenario: secret subcommand - generic	
  Given I have a project
  Given I create the "testfolder" directory                                                                                                 
#Step 1.Create a new secret based on a directory
  Given a "testfolder/file1" file is created with the following lines:
    """                                  
    """   
  Then the step should succeed

  Given a "testfolder/file2" file is created with the following lines:
    """           
    """   
  Then the step should succeed

  Given a "testfolder/file3" file is created with the following lines:
    """           
    """   
  Then the step should succeed

  When I run the :create_secret client command with: 
    | createservice_type | generic |
    | name|secret1-from-file|
    | from_file|./testfolder|

  Then the step should succeed
  When I run the :describe client command with:                                                                           
      | resource | secret |
      | name | secret1-from-file|
  Then the output should match:
      |file1:\s+0\s+bytes|
      |file2:\s+0\s+bytes|
      |file3:\s+0\s+bytes|
#Step 2.Create a new secret based on a file
  Given I create the "testfolder2" directory                                                                                             
  And a "testfolder2/file4" file is created with the following lines:
    """           
1234
    """   
  Then the step should succeed
  When I run the :create_secret client command with: 
    | createservice_type | generic |
    | name|secret2-from-file|
    | from_file|./testfolder2|
                           
  Then the step should succeed
  When I run the :describe client command with:
       | resource | secret |
      | name | secret2-from-file|
  Then the output should contain:
      |file4:  4 bytes|     
#Step 3. Create a new secret with specified keys instead of names on disk
  Given a "testfolder2/id_rsa" file is created with the following lines:
    """           
key12345
    """  
  Then the step should succeed
  Given a "testfolder2/id_rsa.pub" file is created with the following lines:
    """           
key6789012
    """  
  Then the step should succeed
  When I run the :create_secret client command with: 
    | createservice_type | generic |
    | name|secret3-from-file|
    | from_file|ssh-privatekey=./testfolder2/id_rsa|
    | from_file|ssh-publickey=./testfolder2/id_rsa.pub|

  When I run the :describe client command with:                                                                        
      | resource | secret |
      | name | secret3-from-file|
  Then the output should match:
      |ssh-privatekey:\s+8\s+bytes|
      |ssh-publickey:\s+10\s+bytes|

#Step 4. --from-literal
#
  When I run the :create_secret client command with:
    | createservice_type | generic |
    | name|secret4-from-literal|
    | from_literal|key1=abc|
    | from_literal|key2=adbdefg|

  When I run the :describe client command with:
      | resource | secret |                                                                    
      | name |secret4-from-literal| 
  Then the output should match:
      |key1:\s+3\s+bytes|
      |key2:\s+7\s+bytes|
  #Then the output should contain:                                                               
  #    |key1:  3 bytes|   
  #    |key2:  7 bytes|   
#Step 5. --dry-run

  When I run the :create_secret client command with:
    | createservice_type | generic |
    | name|secret5-dry-run|
    | from_literal|key3=aaa|
    | dry_run|true|
  Then the step should succeed
 
  When I run the :get client command with:
      | resource | secret |                                                                    
  Then the output should not contain:                                                               
      |secret5-dry-run|   

#Step 6. --generator
  When I run the :create_secret client command with:
    | createservice_type | generic |
    | name|secret6-1-generator|
    | from_literal|key1=aaa|
    | generator|secret/v2|
  Then the output should match:               
      | Generator.*not.*supported|
  When I run the :create_secret client command with:
    | createservice_type | generic |
    | name|secret6-2-generator| 
    | from_literal|key1=aaa|
    | generator| secret/v1|    
 # Then the step should succeed

  Then the output should match:               
      | secret.*created|      

#Step 7. --output
# --output=json
  When I run the :create_secret client command with:
    | createservice_type | generic |
    | name|secret7-1-output|
    | from_literal|key1=aaa|
    | output|json|
  Then the output should contain:               
      | "kind": "Secret" |  
# --output=yaml
  When I run the :create_secret client command with:
    | createservice_type | generic |
    | name|secret7-2-output|
    | from_literal|key1=aaa|
    | output|yaml|
  Then the output should contain:               
      | kind: Secret |  
  Then the output should not contain:               
      | { |  
# --output=wide
  When I run the :create_secret client command with:
    | createservice_type | generic |
    | name|secret7-3-output|
    | from_literal|key1=aaa|
    | output|wide|
  Then the output should contain:               
      | NAME |      
      | TYPE |      
      | DATA |      
      | AGE |      
# --output=name
  When I run the :create_secret client command with:
    | createservice_type | generic |
    | name|secret7-4-output|
    | from_literal|key1=aaa|
    | output|name|
  Then the output should contain:               
      | secret/secret7-4-output|      

