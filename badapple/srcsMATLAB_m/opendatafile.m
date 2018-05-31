clear ;
data_fname = 'testtext.txt' ; % 这里是文件名
file_id = fopen(data_fname, 'rb');

raw_data = [1:1:1024];
while feof(file_id) == 0
    [row_array, ele_count] = fread(file_id, 1024, 'int8') ;
    if ele_count < 1024 
        break ;
    else
        row_array = int8(row_array');
        
        for i = 1:1024
            if row_array(1,i) < 0
                row_array(1,i) = row_array(1,i)+256;
            end
        end
        
        raw_data = [raw_data; row_array] ;
    end
end
raw_data(1,:)=[] ;
% 关闭文件
fclose(file_id);