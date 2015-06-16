#! /usr/bin/ruby -w

def getParser
  return "
  $S=[]
  $f=false
  $t=true
  
  $s=$f
  $b=$f
  $Q=$f
  
  $M=[1,0]
  $r=[+1,0]
  $l=[-1,0]
  $u=[0,+1]
  $d=[0,-1]
  
  def pop
    return $S.pop
  end
  
  def push(x)
    $S.push x
  end
  
  def parse(c)
    if $b
      $b=$f
      return
    end
    if $s
      if c=='\"'
        $s=$f
      else
        push c
      end
      return
    end
    if c==nil || c==0 || c==' '
    elsif c=='+' || c=='-' || c=='*' || c=='/' || c=='%'
      y=pop
      x=pop
      z=0
      if c=='+'    then z=x+y
      elsif c=='-' then z=x-y
      elsif c=='*' then z=x*y
      elsif c=='/' then z=x/y
      elsif c=='%' then z=x%y
      end
      push z
    elsif c=='!'
      x=pop
      z=(x==0) ? 1:0
    elsif c=='`'
      y=pop
      x=pop
      z=(x>y) ? 1:0
      push z
    elsif c=='>' || c=='<' || c=='^' || c=='v' || c=='?'
      if c=='>'    then $M=$r
      elsif c=='<' then $M=$l
      elsif c=='^' then $M=$u
      elsif c=='v' then $M=$d
      elsif c=='?'
        x=rand 4
        if x==0 then $M=$r
        elsif x==1 then $M=$l
        elsif x==2 then $M=$u
        elsif x==3 then $M=$d
        else print \"INVALID RANDOM NUMBER%i \", x
        end
      end
    elsif c=='_'
      x=pop
      if x==0 then $M=$r
      else         $M=$l
      end
    elsif c=='_' 
      if x==0 then $M=$d
      else         $M=$u
      end
    elsif c=='\"'
      $s=true
    elsif c==':'
      x=pop
      push x
      push x
    elsif c=='\\\\'
      y=pop
      x=pop
      push y
      push x
    elsif c=='$'
      pop
    elsif c=='.'
      x=pop
      print x
    elsif c==','
      x=pop
      print x.chr
    elsif c=='#'
      $b=$t
    elsif c=='g'
      y=pop
      x=pop
      push $G[y][x]
    elsif c=='p'
      y=pop
      x=pop
      v=pop
      $G[y][x]=v.chr
    elsif c=='&'
      x=gets
      push x.to_i
    elsif c=='~'
      x=gets
      push x.to_c
    elsif c=='@'
      $Q=$t
    elsif c>='0' && c<='9'
      x=c.to_i
      push x
    else
      print \"UNKNOWN CHARACTER %c\n\", c
    end
  end
  
  def main
    x=0
    y=0
    until $Q
      parse $G[y][x]
      x+=$M[0]
      y+=$M[1]
    end
  end
  
  main"
end

def readFile(filename)
  file = File.new(filename, 'r')
  data = []

  while line = file.gets
    data.push line
  end
  
  file.close
  return data
end

def writeFile(filename, content)
  file = File.new(filename, 'w')
  
  file.puts content
  
  file.close
end

def createTemp
  name="/tmp/BF-RB-#{rand(16**8).to_s(16).upcase}.rb"
  puts "Creating #{name}..."
  return name
end

def help
  puts "Usage: ruby #{__FILE__} -i <inputfile.bf> [ -o {<outputfile.rb> | !} [-x] ] [ -p <parser.rb> ]"
end

def main(args)
  grid=[]
  parser=[]
  finalCode=""
    
  inputFile=nil
  outputFile=nil
  parserFile=nil
  run=false
  
  i=0
  args.each do |arg|
    if arg=="-i"
      inputFile=args[i+1]
    elsif arg=="-o"
      outputFile=args[i+1]
      if outputFile=="!"
        outputFile=createTemp
      end
    elsif arg=="-p"
      parserFile=args[i+1]
    elsif arg=="-x"
      run=true
    end
    
    i+=1
  end
  
  if inputFile==nil
    puts "No input file specified!"
    return help
  end
  
  # Reading Befunge file and converting to grid  
  lines = readFile inputFile 
  lines.each do |line|
    data=[]
    line.chars.each do |char|
      if char=="\n" then char=" "
      end
      data.push char
    end
    grid.push data
  end

  # Reading parser file
  if parserFile==nil
    parser=[getParser]
  else
    parser=readFile parserFile
  end
  
  # Converting grid to Ruby
  finalCode+="$G=[\n"
  grid.each do | y |
    finalCode+="  ["
    y.each do | x |
      # Escaping
      x=x=='\\'?'\\\\':x
      x=x=='\''?'\\\'':x
      
      finalCode+="'#{x}',"
    end
    finalCode=finalCode[0...-1]
    
    finalCode+="],\n"
  end
  finalCode=finalCode[0...-2]+"\n"
  finalCode+="]\n"
  
  # Adding parser
  finalCode+=parser.join
  
  if outputFile==nil
    puts finalCode
  else
    writeFile outputFile, finalCode
  end
  
  # Running
  if run
    if outputFile==nil
      puts "No output file specified!"
      help
    else
      puts %x[ ruby #{outputFile} ]
      puts "Removing #{outputFile}..."
      %x[ rm #{outputFile} ]
    end
  end
end

main ARGV