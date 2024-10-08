function [decoder_output, survivor_state, cumulated_metric]=viterbi(G,k,channel_output) 
n=size(G,1); 
% size check 
if rem(size(G,2),k)~=0 
    error('Size of G and k do not agree') 
end 
if rem(size(channel_output,2),n)~=0 
    error('channel output not of the right size') 
end 
L=size(G,2)/k; 
number_of_states=2^((L-1)*k); 
% Generate transition, output, input matrix 
for j=0:number_of_states-1 
    for l=0:2^k-1 
        [next_state,memory_contents]=nxt_stat(j,l,L,k); 
        input(j+1,next_state+1)=l; 
        branch_output=rem(memory_contents*G',2); 
        nextstate(j+1,l+1)=next_state; 
        output(j+1,l+1)=bin2deci(branch_output); 
    end 
end 
state_metric=zeros(number_of_states,2); 
depth_of_trellis=length(channel_output)/n; 
channel_output_matrix=reshape(channel_output,n,depth_of_trellis); 
survivor_state=zeros(number_of_states,depth_of_trellis+1); 
% start decoding of non-tail channel outputs. 
for i=1:depth_of_trellis-L+1 
    flag=zeros(1,number_of_states); 
    if i <= L 
        step=2^((L-i)*k); 
    else 
        step=1; 
    end 
    for j=0:step:number_of_states-1 
        for l=0:2^k-1 
            branch_metric=0; 
            binary_output=deci2bin(output(j+1,l+1),n); 
            for ll=1:n 
                branch_metric=branch_metric+metric(channel_output_matrix(ll,i),binary_output(ll)); 
            end 
            if((state_metric(nextstate(j+1,l+1)+1,2) > state_metric(j+1,1)+branch_metric) || flag(nextstate(j+1,l+1)+1)==0) 
                state_metric(nextstate(j+1,l+1)+1,2) = state_metric(j+1,1 )+branch_metric; 
                survivor_state(nextstate(j+1,l+1)+1,i+1)=j; 
                flag(nextstate(j+1,l+1)+1)=1; 
            end 
        end 
    end 
    state_metric=state_metric(:,2:-1:1); 
end 
% start decoding of channel-outputs. 
for i=depth_of_trellis-L+2:depth_of_trellis 
    flag=zeros(1,number_of_states); 
    last_stop=number_of_states/(2^((i-depth_of_trellis+L-2)*k)); 
    for j=0:last_stop-1 
        branch_metric=0; 
        binary_output=deci2bin(output(j+1,1),n); 
        for ll=1:n 
            branch_metric=branch_metric+metric(channel_output_matrix(ll,i),binary_output(ll)); 
        end 
        if((state_metric(nextstate(j+1,1)+1,2) > state_metric(j+1,1)+branch_metric) || flag(nextstate(j+1,1)+1)==0) 
            state_metric(nextstate(j+1,1)+1,2) = state_metric(j+1,1)+branch_metric; 
            survivor_state(nextstate(j+1,1)+1,i+1)=j; 
            flag(nextstate(j+1,1)+1)=1; 
        end 
    end 
    state_metric=state_metric(:,2:-1:1); 
end 
% Generate decoder output from optimal path 
state_sequence=zeros(1,depth_of_trellis+1); 
state_sequence(1,depth_of_trellis)=survivor_state(1,depth_of_trellis+1); 
for i=1:depth_of_trellis 
    state_sequence(1,depth_of_trellis-i+1 )=survivor_state((state_sequence(1,depth_of_trellis+2-i)+1),depth_of_trellis-i+2); 
end 
decoder_output_matrix=zeros(k,depth_of_trellis-L+1); 
for i=1:depth_of_trellis-L+1 
    dec_output_deci=input(state_sequence(1,i)+1,state_sequence(1,i+1)+1); 
    dec_output_bin=deci2bin(dec_output_deci,k); 
    decoder_output_matrix(:,i)=dec_output_bin(k:-1:1)'; 
end 
decoder_output=reshape(decoder_output_matrix,1,k*(depth_of_trellis-L+1)) 
cumulated_metric=state_metric(1,1) 

function distance=metric(x,y)
if x==y
    distance=0;
else
    distance=1;
end

function [next_state,memory_contents]=nxt_stat(current_state,input,L,k) 
binary_state=deci2bin(current_state,k*(L-1)); 
binary_input=deci2bin(input,k); 
next_state_binary=[binary_input,binary_state(1:(L-2)*k)]; 
next_state=bin2deci(next_state_binary); 
memory_contents=[binary_input,binary_state]; 

function y=bin2deci(x) 
l=length(x); 
y=(l-1:-1:0); 
y=2.^y; 
y=x*y'; 

function y=deci2bin(x,l) 
y = zeros(1,l); 
i = 1; 
while x>=0 && i<=l 
    y(i)=rem(x,2); 
    x=(x-y(i))/2; 
    i=i+1; 
end 
y=y(l:-1:1); 
