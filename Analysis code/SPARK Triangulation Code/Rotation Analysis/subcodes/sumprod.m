    function [s] = sumprod(arr1,arr2,n)
        s = 0;
        for i=1:n 
          s = s + arr1(i).*arr2(i) ;
        end
    end