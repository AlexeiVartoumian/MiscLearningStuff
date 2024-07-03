



loan = int(input("please give how much "))

print(type(loan))
print(loan)


def amortized(principal , interestRate , numPayments):
    rate = interestRate / 12    
    return principal * (rate * (1 + rate)** numPayments)  / ((1+rate)**numPayments -1)
   

print(amortized(5000, 0.079 , 36 ))
print(amortized(5000 , 0.099, 36))