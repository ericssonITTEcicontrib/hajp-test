#!/bin/bash
 for i in `seq 1 50`;
 do
 curl -X POST -H "Content-Type:application/xml" -d "<project><builders/><publishers/><buildWrappers/></project>" "localhost:8080/jenkins/createItem?name=AA_TEST_JOB$i"
        done

    sleep 30


     for i in `seq 1 50`;
     do
        echo "localhost:8081/jenkins/job/AA_TEST_JOB$i/"
        curl -I "localhost:8081/jenkins/job/AA_TEST_JOB$i/" 2>/dev/null | head -n 1 | cut -d$' ' -f2
        done

  for J in `seq 1 10`;
         do
         sleep 10
         # Build one each
         for i in `seq 1 50`;
         do
            curl "localhost:8080/jenkins/job/AA_TEST_JOB$i/build"
            done
   done

    sleep 30

     for j in `seq 1 10`;
         do
         # Test Each Build if not 200 return, investigate
         for i in `seq 1 50`;
         do
            echo "localhost:8081/jenkins/job/AA_TEST_JOB$i/$j/"
            curl -I "localhost:8081/jenkins/job/AA_TEST_JOB$i/$j/" 2>/dev/null | head -n 1 | cut -d$' ' -f2
            done
   done



