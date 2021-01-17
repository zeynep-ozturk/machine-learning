function [] = tempcon(x,y,z)

switch x 
    case 'C' 
        switch z
            case 'F'
             1.8*y+32   
            case 'K'
             y+273.15
        end
       
    case 'F' 
        switch z
            case 'C'
             (y-32)/1.8 
            case 'K'
             (y+459.67)/1.8
        end
    case 'K'
        switch z
            case 'C'
             y-273.15
            case 'F'
             y*1.8-459.67
        end
    otherwise
        warning('ERROR')
end
 
end

