require 'creek'
require 'axlsx'
require 'axlsx_rails'
require 'rubygems'
require 'fileutils'





class Parser
 
def initialize(mapping)
#Parse doc incoming
$file_name = mapping[1].to_s
$file_name = $file_name.gsub(" ", "_")
$file_name = $file_name.gsub("(", "")
$file_name = $file_name.gsub(")", "")
cworkbook = Creek::Book.new mapping[0]
cworksheets = cworkbook.sheets


puts "Found #{cworksheets.count} worksheets"

$data = Array.new




cworksheets.each do |cworksheet|
    puts "Reading: #{cworksheet.name}"
    num_rows = 0

    
    
   
    cworksheet.rows.each do |row|
        row_cells = row.values
        num_rows += 1
        #puts "Full row for debugging #{row_cells}"
        $data.push(row.values.join "          ")
        
        # uncomment to print out row values
        #puts row_cells.join "    "
        
    end
  

  
    data_col = Array.new
    col_one = Array.new
    
    


end
#######################################
######## make verbatim start ##########
#######################################
#def makeVerb(topic_code, topic_type, survey_column, topic_title, topic_frame_of_reference, segment, product_mindset , ranking_num, ranking_total)

def makeVerb( values )
run_count = values.size
$run_count_table = run_count

p = Axlsx::Package.new
wb = p.workbook

values.each do |verbatim_call|
    
topic_code               = verbatim_call[0]
topic_type               = verbatim_call[1]
survey_column            = verbatim_call[2]
topic_title              = verbatim_call[3]
topic_frame_of_reference = verbatim_call[4]
segment                  = verbatim_call[5]
product_mindset          = verbatim_call[6]
ranking_num              = verbatim_call[7]
ranking_total            = verbatim_call[8]




distance_counter = 0
distance = 3

distance_row = $data[0].to_s.split("          ")
start_spot = distance_row.index(survey_column)
$g_start_spot = distance_row.index(survey_column)
segment_calc = distance_row.index(segment)
product_start_spot = distance_row.index(product_mindset)
$rank_num = ranking_num
$rank_total = ranking_total

#verbatim styles
title = wb.styles.add_style(:font_name => "Calibri",
                            :sz=> 16,
                            :border=>Axlsx::STYLE_THIN_BORDER,
                            :alignment=>{:horizontal => :center},
                            :b=> true )
                            
body = wb.styles.add_style(:font_name => "Calibri",
                           :sz=> 11,
                           :border=>Axlsx::STYLE_THIN_BORDER,
                           :alignment=>{:horizontal => :left, :wrap_text => true},
                           :bg_color => "ffffff")
                           
                           
                           
intensity = wb.styles.add_style(:font_name => "Calibri",
                           :sz=> 11,
                           :border=>Axlsx::STYLE_THIN_BORDER,
                           :alignment=>{:horizontal => :center, :wrap_text => true},
                           :bg_color => "ffffff")
                           
                           
header = wb.styles.add_style(:font_name => "Calibri",
                           :sz=> 11,
                           :border=>Axlsx::STYLE_THIN_BORDER,
                           :alignment=>{:horizontal => :center, :wrap_text => true},
                           :bg_color => "C0C0C0",
                           :fg_color => "000000",
                           :b=> true)


def valence_calc(value)
   case value.to_i
    when 1
      return "Very Pleasant"
    when 2
      return "Mildly Pleasant"
    when 3
      return "Neutral"
    when 4
      return "Mildly Unpleasant"
    when 5
      return "Very Unpleasant"
   end
end


def map_mindset_value(mindset_value)
    if mindset_value < 1.5
        mindset = "Impassioned"
        elsif mindset_value < 2.6
        mindset = "Attracted"
        elsif mindset_value < 3.5
        mindset = "Apathetic"
        else
        mindset = "Unattracted"
        
        return mindset
    end
end


def mindset_calc( valence1, valence2, valence3 )
   
   mindsetc = valence1.to_i + valence2.to_i + valence3.to_i
   mindsetc = mindsetc / 3
   
   #return mindsetc
  return map_mindset_value(mindsetc)
   
end



def r_calc( col_val, statement_rank, type  )
    #gets types below from their respective columns
    #col_val = value in the column, 2, 3, 4 or whatever, tells the function which valence/statement to get
    #statement_rank = number of statements, maps to ranking total
    #statement_eval = number of statements evaluated
    #type = emotion/intensity/why/valence
    
    #type calc vals
    type_val = 0
    case type
        when type = "emotion"
           type_val = 2
        when type = "intensity"
           type_val = 3
        when type = "why"
           type_val = 4
        when type = "valence"
           type_val = 5
    end
    #leave that 6 in there, it corresponds to how the mapping files are setup
    find_att   = (col_val.to_i * 6) - 6
    att_offset = statement_rank.to_i + $g_start_spot
    
    
    return find_att + att_offset + type_val

end


def r_mindset_calc( statement_rank, statement_count, row_num)
    data_row = $data[row_num].to_s.split("          ") # Parses individual rows from sheet
    #type is always valence
    #
    count = 0
    calc_total = 0
    while count < statement_rank.to_i
        
       r_calc_column = $g_start_spot + count
       
       r_calc_value = data_row[r_calc_column]
       
       
       if r_calc_value.to_i <= statement_count.to_i
           calc_total = data_row[r_calc(r_calc_value, statement_rank , "valence" )].to_i + calc_total
        
       end
       count = count + 1
    end
    
    mindsetc = calc_total / statement_count.to_i
    
    return map_mindset_value(mindsetc)
   
end

# this is 3x only 
s11 = start_spot       # Emotion
s12 = start_spot + 4   # Intensity
s13 = start_spot + 5   # Why
s14 = start_spot + 6   # Valence
s21 = start_spot + 1   # Emotion
s22 = start_spot + 8   # Intensity
s23 = start_spot + 9   # Why
s24 = start_spot + 10  # Valence
s31 = start_spot + 2   # Emotion
s32 = start_spot + 12  # Intensity
s33 = start_spot + 13  # Why
s34 = start_spot + 14  # Valence

# this is 1x only
ss11 = start_spot       # Emotion
ss12 = start_spot + 1   # Intensity
ss13 = start_spot + 2   # Why
ss14 = start_spot + 3   # Valence

p14 = product_start_spot + 6   # Valence
p24 = product_start_spot + 10  # Valence
p34 = product_start_spot + 14  # Valence



row_count = 0
pop_row_count = 0



 worksheet_name = "#{topic_code} - #{topic_title}"
 worksheet_name = worksheet_name.truncate(30)
 worksheet_name = worksheet_name.gsub("/", "_")
 wb.add_worksheet(:name=> "#{worksheet_name}") do |sheet|
     
     #i_value = $data.size.to_i
     #i_value = i_value - 2
     #sheet.add_table "A3:I52"

#get 3x
case topic_type
  when "standard_3x"
   $data.each do |row|
        if row == $data[0]
            
        puts "Skipping Main Row"
        row_count = row_count + 1
        elsif row == $data[1]
        
        puts "Skipping second row"
        row_count = row_count + 1
        else
        data_row = $data[row_count].to_s.split("          ") # Parses individual rows from sheet
                              # increments count
        
 
 sheet.add_row [ data_row[s11] , data_row[s12], data_row[s13] , data_row[s14].to_i , valence_calc(data_row[s14]), mindset_calc(data_row[s14],data_row[s24],data_row[s34]), data_row[segment_calc] , mindset_calc(data_row[p14],data_row[p24],data_row[p34]) , data_row[0] ], :style=>body
        
        sheet.add_row [ data_row[s21] , data_row[s22] , data_row[s23] , data_row[s24].to_i , valence_calc(data_row[s24]), mindset_calc(data_row[s14],data_row[s24],data_row[s34]), data_row[segment_calc] , mindset_calc(data_row[p14],data_row[p24],data_row[p34]) , data_row[0] ], :style=>body
        
        sheet.add_row [ data_row[s31] , data_row[s32] , data_row[s33] , data_row[s34].to_i , valence_calc(data_row[s34]), mindset_calc(data_row[s14],data_row[s24],data_row[s34]), data_row[segment_calc] , mindset_calc(data_row[p14],data_row[p24],data_row[p34]) , data_row[0] ], :style=>body
        row_count = row_count + 1
       end
        
        
       
    end
   pop_row_count = (row_count * 3) - 2
   
   sheet.rows.each do |row|
      
      row.cells[1].style = intensity
      
   end
   
   sheet.rows.sort_by!{ |row| [row.cells[3].value.to_i, -row.cells[1].value.to_i] }

   sheet.add_row ["Emotion", "Intensity", "Why", "S" , "Valence", "Mindset", "Segment", "Product Mindset" ,"Response ID"], :style=>header
   sheet.rows.insert 0,  sheet.rows.delete(sheet.rows[sheet.rows.length-1])

   sheet.add_row [topic_frame_of_reference], :style=>title
   sheet.rows.insert 0,  sheet.rows.delete(sheet.rows[sheet.rows.length-1])

   sheet.add_row [topic_title], :style=>title
   sheet.rows.insert 0,  sheet.rows.delete(sheet.rows[sheet.rows.length-1])
   
   
   sheet.merge_cells "A1:I1"
   sheet.merge_cells "A2:I2"
   sheet.column_widths 25, 25, 80, 5, 25, 25, 25, 25, 25
   
   # standard_1x
   when "standard_1x"
   $data.each do |row|
       if row == $data[0]
           
           puts "Skipping Main Row"
           row_count = row_count + 1
           elsif row == $data[1]
           
           puts "Skipping second row"
           row_count = row_count + 1
           else
           data_row = $data[row_count].to_s.split("          ") # Parses individual rows from sheet
           # increments count
           
           
           
           sheet.add_row [ data_row[ss11] , data_row[ss12] , data_row[ss13] , data_row[ss14].to_i , valence_calc(data_row[ss14]), data_row[s14], data_row[segment_calc] , mindset_calc(data_row[p14],data_row[p24],data_row[p34]) , data_row[0] ], :style=>body
           
           
           
           row_count = row_count + 1
       end
       
   end
   pop_row_count = (row_count * 3) - 2
   
   sheet.rows.each do |row|
       
       row.cells[1].style = intensity
       
   end
   
   sheet.rows.sort_by!{ |row| [row.cells[3].value.to_i, -row.cells[1].value.to_i] }
   
   sheet.add_row ["Emotion", "Intensity", "Why", "S" , "Valence", "Mindset", "Segment", "Product Mindset" ,"Response ID"], :style=>header
   sheet.rows.insert 0,  sheet.rows.delete(sheet.rows[sheet.rows.length-1])
   
   sheet.add_row [topic_frame_of_reference], :style=>title
   sheet.rows.insert 0,  sheet.rows.delete(sheet.rows[sheet.rows.length-1])
   
   sheet.add_row [topic_title], :style=>title
   sheet.rows.insert 0,  sheet.rows.delete(sheet.rows[sheet.rows.length-1])
   
   
   sheet.merge_cells "A1:I1"
   sheet.merge_cells "A2:I2"
   sheet.column_widths 25, 25, 80, 5, 25, 25, 25, 25, 25
   
   #Ranking
   when "ranking"
   original_start = s11
   
   while s11 <= original_start + $rank_total.to_i

   if s11 == original_start
       
       $data.each do |row|
           data_row = $data[row_count].to_s.split("          ") # Parses individual rows from sheet
           
           if $rank_num.to_i < data_row[s11].to_i
               puts "Not evaluated statement, skipping"
               row_count = row_count + 1
               
               elsif row == $data[0]
               
               puts "Skipping Main Row"
               row_count = row_count + 1
               elsif row == $data[1]
               
               puts "Skipping second row"
               row_count = row_count + 1
               else
               
               
               
               sheet.add_row [data_row[r_calc(data_row[s11], $rank_total , "emotion" )] , data_row[r_calc(data_row[s11], $rank_total , "intensity" )], data_row[r_calc(data_row[s11], $rank_total , "why" ) ].to_i, "", valence_calc(data_row[r_calc(data_row[s11], $rank_total , "valence" )]), r_mindset_calc( $rank_total, $rank_num, row_count), data_row[segment_calc] , mindset_calc(data_row[p14],data_row[p24],data_row[p34]) , data_row[0] ], :style=>body
               
               
               row_count = row_count + 1
           end
       end
       
       sheet.rows.each do |row|
           
           row.cells[1].style = intensity
           
       end
       
       sheet.rows.sort_by!{ |row| [row.cells[3].value.to_i, -row.cells[1].value.to_i] }
       
       sheet.add_row ["Emotion", "Intensity", "Why", "S" , "Valence", "Mindset", "Segment", "Product Mindset" ,"Response ID"], :style=>header
       sheet.rows.insert 0,  sheet.rows.delete(sheet.rows[sheet.rows.length-1])
       
       sheet.add_row [topic_frame_of_reference], :style=>title
       sheet.rows.insert 0,  sheet.rows.delete(sheet.rows[sheet.rows.length-1])
       
       sheet.add_row [topic_title], :style=>title
       sheet.rows.insert 0,  sheet.rows.delete(sheet.rows[sheet.rows.length-1])
       
       
       sheet.merge_cells "A1:I1"
       sheet.merge_cells "A2:I2"
       sheet.column_widths 25, 25, 80, 5, 25, 25, 25, 25, 25
       
       
   else
   
   row_count = 0
   worksheet_name = "#{topic_code} - #{topic_title}_#{s11}"
   worksheet_name = worksheet_name.truncate(30)
   worksheet_name = worksheet_name.gsub("/", "_")
   wb.add_worksheet(:name=> "#{worksheet_name}") do |sheet|
       
       sheet.add_row [topic_title], :style=>title
       
       sheet.add_row [topic_frame_of_reference], :style=>title
       sheet.merge_cells "A1:I1"
       sheet.merge_cells "A2:I2"
       sheet.add_row ["Emotion", "Intensity", "Why", "S" , "Valence", "Mindset", "Segment", "Product Mindset" ,"Response ID"]
       
       
       $data.each do |row|
           data_row = $data[row_count].to_s.split("          ") # Parses individual rows from sheet
           
           if $rank_num.to_i < data_row[s11].to_i
               puts "Not evaluated statement, skipping"
               row_count = row_count + 1
               
               elsif row == $data[0]
               
               puts "Skipping Main Row"
               row_count = row_count + 1
               elsif row == $data[1]
               
               puts "Skipping second row"
               row_count = row_count + 1
               else
               
               
               
               sheet.add_row [data_row[r_calc(data_row[s11], $rank_total , "emotion" )] , data_row[r_calc(data_row[s11], $rank_total , "intensity" )], data_row[r_calc(data_row[s11], $rank_total , "why" ) ].to_i, "", valence_calc(data_row[r_calc(data_row[s11], $rank_total , "valence" )]), r_mindset_calc( $rank_total, $rank_num, row_count), data_row[segment_calc] , mindset_calc(data_row[p14],data_row[p24],data_row[p34]) , data_row[0] ], :style=>body
               
               
               row_count = row_count + 1
           end
       end
       sheet.rows.each do |row|
           
           row.cells[1].style = intensity
           
       end
       
       
       sheet.rows.sort_by!{ |row| [row.cells[3].value.to_i, -row.cells[1].value.to_i] }
       
       sheet.add_row ["Emotion", "Intensity", "Why", "S" , "Valence", "Mindset", "Segment", "Product Mindset" ,"Response ID"], :style=>header
       sheet.rows.insert 0,  sheet.rows.delete(sheet.rows[sheet.rows.length-1])
       
       sheet.add_row [topic_frame_of_reference], :style=>title
       sheet.rows.insert 0,  sheet.rows.delete(sheet.rows[sheet.rows.length-1])
       
       sheet.add_row [topic_title], :style=>title
       sheet.rows.insert 0,  sheet.rows.delete(sheet.rows[sheet.rows.length-1])
       
       
       sheet.merge_cells "A1:I1"
       sheet.merge_cells "A2:I2"
       sheet.column_widths 25, 25, 80, 5, 25, 25, 25, 25, 25
   end

   

  end
   s11 = s11 + 1
   pop_row_count = (row_count * 3) - 2
 end
   
   
   
   
   else puts "Not a known topic code"




end # end topic type case





sheet.add_table "A3:I#{pop_row_count-1}"



 end # end worksheet creator
#test commit number 2


end # end while to catch all sheets

p.serialize($file_name)
file = $file_name.to_s
FileUtils.mv $file_name, "./public/uploads/#{$file_name}/verbatim_#{$file_name}"




end



#######################################
########## make graph start ###########
#######################################

#def makeGraph(g_topic_code, g_topic_type, graph_topics, g_topic_title, g_ranking_num, g_ranking_total )
def makeGraph(values)
    
    $segment_a = Array.new
    ######### Array positions of values ########
     #   valence = 4
     #   mindset = 5
     #   segment = 6
     #   product_mindset = 7
    
    #Open recently created verbatim and parse it
    verbatim = File.open("./public/uploads/#{$file_name}/verbatim_#{$file_name}")
    
    
    cworkbook = Creek::Book.new verbatim
    cworksheets = cworkbook.sheets
    puts "Found #{cworksheets.count} verbatim worksheets"
    
    # Where everything lives for graphs
    $gdata = Hash.new
    $g_data_raw = Array.new
    #################################   Percent Positive Calcs   ###############################
    #Parse verbatim by sheet
    cworksheets.each do |cworksheet|
        
        
        
        
        
        puts "Reading verbatims for graph generation, sheet: #{cworksheet.name}"
        num_rows = 0
    
        #get the contents of the sheet and put them in an array
        cworksheet.rows.each do |row|
            row_cells = row.values
            num_rows += 1
            $g_data_raw.push(row.values.join "          ")
        end
        #Percent Positive start values
        row_count = 0
        positive = 0
        neutral = 0
        negative = 0
        #parse array to get values for building graphs
        $g_data_raw.each do |row|
            
            if row == $g_data_raw[0]
                
                puts "Skipping Main Row"
                row_count = row_count + 1
                elsif row == $g_data_raw[1]
                
                puts "Skipping second row"
                row_count = row_count + 1
                elsif row == $g_data_raw[2]
                puts "Skipping third row"
                row_count = row_count + 1
                
                else
                data_row = $g_data_raw[row_count].to_s.split("          ") # Parses individual rows from sheet
                
                if data_row[4] == "Very Pleasant"
                    positive = positive + 1
                    elsif data_row[4] == "Mildly Pleasant"
                    positive = positive + 1
                    elsif data_row[4] == "Neutral"
                    neutral = neutral + 1
                    elsif data_row[4] == "Mildly Unpleasant"
                    negative = negative + 1
                    elsif data_row[4] == "Very Unpleasant"
                    negative = negative + 1
                end
                #add segments to array so you can manipulate it later
                
                $segment_a.push(data_row[6])
                
                
                row_count = row_count + 1
            end
            
            
        end # End for parsing calculation
        $total = positive + neutral + negative
        $per_positive = (positive.to_f / $total.to_f).round(2) * 100
        $per_neutral  = (neutral.to_f  / $total.to_f).round(2) * 100
        $per_negative = (negative.to_f / $total.to_f).round(2) * 100
    
        puts "per positive #{$per_positive}"
        puts "per negative #{$per_negative}"
        puts "per neutral  #{$per_neutral}"
        
        
        
    
        #################################   Segment Calcs   ###############################
        #Run segment calcs, this is all dynamic and should work with any number of segments
        row_count       = 0
        $seg_array      = Array.new
        $uniq_seg_names = Array.new
        $uniq_segs      = Array.new
        
        
        #how many segments are they and what are the unique vals
        $num_of_segs     = $segment_a.uniq.length
        $uniq_seg_names  = $segment_a.uniq
        
        
        #turn segs values into a nested array
        $uniq_seg_names.each do |seg|
            array_spot = $uniq_seg_names.index(seg)
            $uniq_segs[array_spot] = Array.new
        end


      #parse array to get values for building segment graphs
      $g_data_raw.each do |row|
            
            
            if row == $g_data_raw[0]

                puts "Skipping Main Row"
                row_count = row_count + 1
                
                elsif row == $g_data_raw[1]
                puts "Skipping second row"
                row_count = row_count + 1
                
                elsif row == $g_data_raw[2]
                puts "Skipping third row"
                row_count = row_count + 1
                
                else
                data_row = $g_data_raw[row_count].to_s.split("          ") # Parses individual rows from sheet
                
             
                $uniq_seg_names.each do |seg| # see what segment is on the row we're looking at
                    array_spot = $uniq_seg_names.index(seg)
                    if seg == data_row[6]
                        
                       $uniq_segs[array_spot].push(data_row[4]) # Put the valence into an array corresponding to the segment title
                    end
                
               end
                row_count = row_count + 1
            end
            
      end # End segment row parsing
      
            $seg_values = Hash.new
            $uniq_seg_names.each do |seg|
               array_spot = $uniq_seg_names.index(seg)
               positive = 0
               neutral = 0
               negative = 0
               
               
                temp_array = Array.new
                temp_array = $uniq_segs[array_spot]
                #$uniq_segs[array_spot].each do |val|
                temp_array.each do |val|
                    if val == "Very Pleasant"
                        positive = positive + 1
                        elsif val == "Mildly Pleasant"
                        positive = positive + 1
                        elsif val == "Neutral"
                        neutral = neutral + 1
                        elsif val == "Mildly Unpleasant"
                        negative = negative + 1
                        elsif val == "Very Unpleasant"
                        negative = negative + 1
                    end
                
                
               end
                $s_total = positive + neutral + negative
                $s_total_used = $total - $s_total
                $s_per_positive = (positive.to_f / $s_total.to_f).round(2)
                $s_per_neutral  = (neutral.to_f  / $s_total.to_f).round(2)
                $s_per_negative = (negative.to_f / $s_total.to_f).round(2)
       
                
                
               
                $seg_values[seg] = [$s_per_positive, $s_per_neutral, $s_per_negative, $s_total , $s_total_used]
                
                
            end
            
            
            
            # end # End for segment ID calculation
        
        
        
        
        
        ### That's what seg values looks like it's a hash with the key being the segment name
        #$seg_values[unique_seg_names(seg)] = (per_positive, per_neutral, per_negative, total_used, total)

        $seg_values = $seg_values.reject { |k,v| k.nil? }
        
        $ts = [ $per_positive, $per_neutral, $per_negative,  $total, $total]
        title = cworksheet.name[0..2].strip
        $gdata[title] = [$ts]
        
       
        ##TODO - Filter out nil values from
         $seg_values.each do |key, value|
             title = cworksheet.name[0..2].strip
             $gdata[title].push(key, value)
             
        end
         
      
      end # End for each worksheet
    puts $gdata
    #create new xlsx doc
    p = Axlsx::Package.new
    wb = p.workbook
    chart_style = wb.styles.add_style(:font_name => "Calibri",
                                      :sz=> 11,
                                      :fg_color => "000000",
                                      :b=> true)
    
    
    values.each do |graph_call|
        
        g_topic_code          = graph_call[0]
        g_topic_type          = graph_call[1]
        graph_topics          = graph_call[2]
        g_topic_title         = graph_call[3]
        g_ranking_num         = graph_call[4]
        g_ranking_total       = graph_call[5]
        
        $graph_topics_a = Array.new
        $graph_topics_a = graph_topics.split(",")
        $graph_topics_s = Array.new
        $graph_topics_s = graph_topics.split(",")

row_count = 0
$ts_positive    = Array.new
$ts_positive.push("Positive")
$ts_neutral     = Array.new
$ts_neutral.push("Neutral")
$ts_negative    = Array.new
$ts_negative.push("Negative")
$ts_total      = Array.new
$ts_total.push("Total")
$ts_total_used  = Array.new
$ts_total_used.push("Message Index")


$graph_topics_a.each do |topic|

    ts_data = $gdata[topic.strip]
    ts_data_a = ts_data[0]

    
    $ts_positive.push(ts_data_a[0])
    $ts_neutral.push(ts_data_a[1])
    $ts_negative.push(ts_data_a[2])
    $ts_total_used.push(ts_data_a[3])
    $ts_total.push(ts_data_a[4])
    
end


g_worksheet_name = "#{g_topic_code} (TS) - #{g_topic_title}"
g_worksheet_name = g_worksheet_name.truncate(30)
g_worksheet_name = g_worksheet_name.gsub("/", "_")
#  TS
wb.add_worksheet(:name=> "#{g_worksheet_name}") do |sheet|
    
    sheet.add_row [g_topic_title], :sz => 12, :font_name=>"Calibri", :b => true, :alignment => { :horizontal => :center, :vertical => :center , :wrap_text => true}
    
    sheet.add_row [g_topic_type], :sz => 12, :font_name=>"Calibri", :b => true, :alignment => { :horizontal => :center, :vertical => :center , :wrap_text => true}


            sheet.add_row  $graph_topics_a.unshift(""), :style => chart_style
            sheet.add_row  $ts_positive , :style => chart_style #positive
            sheet.add_row  $ts_neutral, :style => chart_style #neutral
            sheet.add_row  $ts_negative, :style => chart_style #negative
            sheet.add_row  $ts_total, :style => chart_style #total
            sheet.add_row  $ts_total_used, :style => chart_style #message index
            
            num_of_topics = $graph_topics_a.size - 1
           
            case num_of_topics
                when 1
                   $p_cells   = "B4:B4"
                   $neu_cells = "B5:B5"
                   $neg_cells = "B6:B6"
                when 2
                   $p_cells   = "B4:C4"
                   $neu_cells = "B5:C5"
                   $neg_cells = "B6:C6"
                when 3
                   $p_cells   = "B4:D4"
                   $neu_cells = "B5:D5"
                   $neg_cells = "B6:D6"
                when 4
                   $p_cells   = "B4:E4"
                   $neu_cells = "B5:E5"
                   $neg_cells = "B6:E6"
                when 5
                   $p_cells   = "B4:F4"
                   $neu_cells = "B5:F5"
                   $neg_cells = "B6:F6"
                when 6
                   $p_cells   = "B4:G4"
                   $neu_cells = "B5:G5"
                   $neg_cells = "B6:G6"
                when 7
                   $p_cells   = "B4:H4"
                   $neu_cells = "B5:H5"
                   $neg_cells = "B6:H6"
                when 8
                   $p_cells   = "B4:I4"
                   $neu_cells = "B5:I5"
                   $neg_cells = "B6:I6"
                when 9
                   $p_cells   = "B4:J4"
                   $neu_cells = "B5:J5"
                   $neg_cells = "B6:J6"
                when 10
                   $p_cells   = "B4:K4"
                   $neu_cells = "B5:K5"
                   $neg_cells = "B6:K6"
                when 11
                   $p_cells   = "B4:L4"
                   $neu_cells = "B5:L5"
                   $neg_cells = "B6:L6"
                when 12
                   $p_cells   = "B4:M4"
                   $neu_cells = "B5:M5"
                   $neg_cells = "B6:M6"
                when 13
                   $p_cells   = "B4:N4"
                   $neu_cells = "B5:N5"
                   $neg_cells = "B6:N6"
                when 14
                   $p_cells   = "B4:O4"
                   $neu_cells = "B5:O5"
                   $neg_cells = "B6:O6"
                when 15
                   $p_cells   = "B4:P4"
                   $neu_cells = "B5:P5"
                   $neg_cells = "B6:P6"
                   
                else
                puts "Out of bounds, double check number of permitted topics per graph."
            end
      
     
     sheet.add_chart(Axlsx::Bar3DChart, :start_at => "B10", :end_at => "O32", :title=>"", :show_legend => false, :barDir => :col, :grouping => :percentStacked) do |chart|
              chart.add_series :data => sheet[$p_cells],:fg_color => "ffffff" , :colors => ['365e92', '365e92', '365e92']
              chart.add_series :data => sheet[$neu_cells], :fg_color => "ffffff" , :colors => ['a5a5a5', 'a5a5a5', 'a5a5a5']
              chart.add_series :data => sheet[$neg_cells], :fg_color => "ffffff" , :colors => ['be0712', 'be0712', 'be0712']
              chart.d_lbls.show_val = true
              chart.d_lbls.show_percent = true
              chart.d_lbls.show_legend_key = false
              chart.valAxis.gridlines = false
              chart.catAxis.gridlines = false
              chart.valAxis.scaling.orientation = :minMax
              chart.valAxis.format_code = "Percentage"
              chart.d_lbls.show_leader_lines = true
              #segment name is an array, this has all the segments in it
          #so this chart needs to show all the segents and their names
          #chart.catAxis.title = "#{$segment_name}"
          
         
      end




end





#determine how many times to iterate
$topic_count = 0
$graph_topics_s.each do |topic|
    ts_data = $gdata[topic.strip]
      if ts_data[0].class == Array
        ts_data.delete_at(0)
      else
        puts "Not deleting segment titles"
      end
    count = ts_data.size
    $num_of_segments = count / 2
    $topic_count =+ 1
 end
puts "Number of segments #{$num_of_segments}"
$segment_name = Array.new
$ts_data = Array.new
$g_spot = 0
$seg_count = 0

while $seg_count < $num_of_segments
    $graph_topics_s = Array.new
    $graph_topics_s = graph_topics.split(",")

   
    #clear out array of ts values
    $ts_positive.clear
    $ts_positive.push("Positive")
    $ts_neutral.clear
    $ts_neutral.push("Neutral")
    $ts_negative.clear
    $ts_negative.push("Negative")
    $ts_total_used.clear
    $ts_total_used.push("Message Index")
    $ts_total.clear
    $ts_total.push("Total")
    #get values for segment

    
    puts " full gdata before #{$gdata}"
    
    $graph_topics_s.each do |topic|
        puts "topic being looked at #{topic}"
        $ts_data = $gdata[topic.strip]
        puts "gdata for debuggin #{$gdata[topic.strip]}"
        puts " full gdata after #{$gdata}"
        puts "ts data #{$ts_data}"
        if $seg_count == 0
            $g_spot = 1
            
            else
            
           $g_spot = ($seg_count * 2) + 1
        
        end
        
        ts_data_a = $ts_data[$g_spot.to_i]
        puts "TS Data a for segments #{ts_data_a}"
  
        $ts_positive.push(ts_data_a[0])
        $ts_neutral.push(ts_data_a[1])
        $ts_negative.push(ts_data_a[2])
        $ts_total_used.push(ts_data_a[3])
        $ts_total.push(ts_data_a[4])
  
        $name_count = $seg_count * 2

        $segment_name.push($ts_data[$name_count.to_i])

        $segment_name = $segment_name.uniq
     

        puts "segment name array #{$segment_name}"
    end
    $seg_title = "#{g_topic_code} #{$segment_name[$seg_count]} - #{g_topic_title}"
    $seg_title = $seg_title.truncate(30)
    $seg_title = $seg_title.gsub("/", "_")
 
    

#  Per Segments
wb.add_worksheet(:name=> "#{$seg_title}") do |sheet|
    
    sheet.add_row [g_topic_title], :sz => 12, :b => true, :alignment => { :horizontal => :center, :vertical => :center , :wrap_text => true}
    
    sheet.add_row [$seg_title], :sz => 12, :b => true, :alignment => { :horizontal => :center, :vertical => :center , :wrap_text => true}
    
    
    
    
    sheet.add_row  $graph_topics_s.unshift("")
    sheet.add_row  $ts_positive #positive
    sheet.add_row  $ts_neutral #neutral
    sheet.add_row  $ts_negative #negative
    sheet.add_row  $ts_total #total
    sheet.add_row  $ts_total_used #message index
    
    
    
   
    num_of_topics = $graph_topics_s.size - 1

    
    case num_of_topics
        when 1
        $p_cells   = "B4:B4"
        $neu_cells = "B5:B5"
        $neg_cells = "B6:B6"
        when 2
        $p_cells   = "B4:C4"
        $neu_cells = "B5:C5"
        $neg_cells = "B6:C6"
        when 3
        $p_cells   = "B4:D4"
        $neu_cells = "B5:D5"
        $neg_cells = "B6:D6"
        when 4
        $p_cells   = "B4:E4"
        $neu_cells = "B5:E5"
        $neg_cells = "B6:E6"
        when 5
        $p_cells   = "B4:F4"
        $neu_cells = "B5:F5"
        $neg_cells = "B6:F6"
        when 6
        $p_cells   = "B4:G4"
        $neu_cells = "B5:G5"
        $neg_cells = "B6:G6"
        when 7
        $p_cells   = "B4:H4"
        $neu_cells = "B5:H5"
        $neg_cells = "B6:H6"
        when 8
        $p_cells   = "B4:I4"
        $neu_cells = "B5:I5"
        $neg_cells = "B6:I6"
        when 9
        $p_cells   = "B4:J4"
        $neu_cells = "B5:J5"
        $neg_cells = "B6:J6"
        when 10
        $p_cells   = "B4:K4"
        $neu_cells = "B5:K5"
        $neg_cells = "B6:K6"
        when 11
        $p_cells   = "B4:L4"
        $neu_cells = "B5:L5"
        $neg_cells = "B6:L6"
        when 12
        $p_cells   = "B4:M4"
        $neu_cells = "B5:M5"
        $neg_cells = "B6:M6"
        when 13
        $p_cells   = "B4:N4"
        $neu_cells = "B5:N5"
        $neg_cells = "B6:N6"
        when 14
        $p_cells   = "B4:O4"
        $neu_cells = "B5:O5"
        $neg_cells = "B6:O6"
        when 15
        $p_cells   = "B4:P4"
        $neu_cells = "B5:P5"
        $neg_cells = "B6:P6"
        
        else
        puts "Out of bounds, double check number of permitted topics per graph."
    end
  
    
    sheet.add_chart(Axlsx::Bar3DChart, :start_at => "D9", :end_at => "H21",  :barDir => :col, :grouping => :percentStacked) do |chart|
        chart.add_series :data => sheet[$p_cells], :title => "Positive", :colors => ['365e92', '365e92', '365e92']
        chart.add_series :data => sheet[$neu_cells], :title => "Neutral", :colors => ['a5a5a5', 'a5a5a5', 'a5a5a5']
        chart.add_series :data => sheet[$neg_cells], :title => "Negative", :colors => ['be0712', 'be0712', 'be0712']
        chart.valAxis.gridlines = false
        chart.catAxis.gridlines = false
        chart.catAxis.title = "#{$segment_name[0]}"
       
       $seg_count += 1
      
    end


end


end





    #p.serialize('test_graph.xlsx')
  
end
    p.serialize($file_name)
    file = $file_name.to_s
    FileUtils.mv $file_name, "./public/uploads/#{$file_name}/graphs_#{$file_name}"

end

end


#makeGraph("P1", "standard_3x", "Q378", "Role in Caring for Patient" , "When I think about my role in caring for my patients with Pseudobulbar affect (PBA), I feel:", "SEG", "Q151")




end#end parser
#end
