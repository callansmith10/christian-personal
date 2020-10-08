#Author: Christian Smith
#Description: Extended research on Alan and Hastings

import numpy as np
import matplotlib.pyplot as plt
from scipy.integrate import odeint
from mpl_toolkits.mplot3d import Axes3D


def Fw(w,t,a1,b1,a2,b2,d1,d2):
    x=w[0]
    y=w[1]
    z=w[2]

    f1=a1*x/(1+(b1*x))
    f2=a2*y/(1+(b2*y))

    xdot=x*(1-x)-f1*y
    ydot=(f1*y)-(f2*z)-(d1*y)
    zdot=(f2*z)-(d2*z)

    Fw_arr=[xdot,ydot,zdot]
    return Fw_arr

a1=5.0
b1_arr=np.arange(2.0,6.2+0.1,0.1)
b1=3.0
a2=0.1
b2=2.0
d1=0.4
d2=0.01

#note: using w to denote the array of x,y,z, Fw to denote array of dx/dt,dy/dt,dz/dt

w0=[1,1,1]
tstart=0
tend=10000
dt=1
t=np.arange(tstart,tend+dt,dt)

w=odeint(Fw,w0,t,args=(a1,b1,a2,b2,d1,d2))

################### FIGURE 2 ###############################

plt.plot(t,w[:,0])
plt.xlim(8000,10000)
plt.xlabel('t')
plt.ylabel('x')
plt.show()

plt.figure()
plt.plot(t,w[:,1])
plt.xlim(8000,10000)
plt.ylim(0,0.5)
plt.xlabel('t')
plt.ylabel('y')
plt.show()

plt.figure()
plt.plot(t,w[:,2])
plt.xlim(8000,10000)
plt.ylim(7,11)
plt.xlabel('t')
plt.ylabel('z')
plt.show()

#3-d phase plot

from mpl_toolkits.mplot3d import Axes3D
fig=plt.figure()
ax=Axes3D(fig)
ax.plot(w[8000:,0],w[8000:,1],w[8000:,2])
ax.set_xlim(0,1)
ax.set_ylim(0.5,0)
ax.set_zlim(7.5,10.5)
ax.set_xlabel('x')
ax.set_ylabel('y')
ax.set_zlabel('z')
plt.show()

####################### FIGURE 3 ###################################
dx0=0.01 #changing the x initial condition by 0.01
w0_2=[1+dx0,1,1]

#do the integration again
w2=odeint(Fw,w0_2,t,args=(a1,b1,a2,b2,d1,d2))

#plot the two solutions
plt.figure()
plt.plot(t,w[:,0])
plt.plot(t,w2[:,0])
plt.xlim(9500,10000)
plt.xlabel('t')
plt.ylabel('x')
plt.show()
####################### FIGURE 4 ###################################

#finding local maxima by finding the values in the array that are larger than both of the values to either side

#fig 4a
#b1 from 2.2 to 3.2
start=2.2
end=3.2
step=0.01
b1_arr_4a=np.arange(start,end+step,step)
b1_arr=b1_arr_4a

zmax_matrix=[]
for i in range(len(b1_arr)):
    print('i={}'.format(i))
    zmax_arr=[]
    b1=b1_arr[i]
    w=odeint(Fw,w0,t,args=(a1,b1,a2,b2,d1,d2))
    z=w[:,2]

    #only consider later timesteps so the solutions are on the attractor
    for k in range(8000,len(z)-50):
        print('k={}'.format(k))

        if z[k]>z[k-1] and z[k]>z[k+1]:
            #second condition is to just find the highest of the local maxima
            #secondary local maxima are also cut in the figures in paper for clarity
            #choosing +/- 50 for this condition based on looking at graph
            if z[k]>z[k-50] and z[k]>z[k+50]:
                plt.plot([b1],[z[k]],color='k',marker='.',markersize=1)

plt.show()

#fig 4b
#b1 from 3 to 6.5
start=3
end=6.5
step=0.01
b1_arr_4b=np.arange(start,end+step,step)
b1_arr=b1_arr_4b

zmax_matrix=[]
for i in range(len(b1_arr)):
    print('i={}'.format(i))
    zmax_arr=[]
    b1=b1_arr[i]
    w=odeint(Fw,w0,t,args=(a1,b1,a2,b2,d1,d2))
    z=w[:,2]


    for k in range(8000,len(z)-50):
        print('k={}'.format(k))
        if z[k]>z[k-1] and z[k]>z[k+1]:
            if z[k]>z[k-50] and z[k]>z[k+50]:
                plt.plot([b1],[z[k]],color='k',marker='.',markersize=1)

plt.show()

#fig 4c
#b1 from 2.25 to 2.6
start=2.25
end=2.6
step=0.001
b1_arr_4c=np.arange(start,end+step,step)
b1_arr=b1_arr_4c

zmax_matrix=[]
for i in range(len(b1_arr)):
    print('i={}'.format(i))
    zmax_arr=[]
    b1=b1_arr[i]
    w=odeint(Fw,w0,t,args=(a1,b1,a2,b2,d1,d2))
    z=w[:,2]

    for k in range(8000,len(z)-50):
        print('k={}'.format(k))

        if z[k]>z[k-1] and z[k]>z[k+1]:
            if z[k]>z[k-50] and z[k]>z[k+50]:
                plt.plot([b1],[z[k]],color='k',marker='.',markersize=1)

plt.show()

####################### FIGURE 5 ###################################
#poincare diagram

a1=5.0
b1=3.0
a2=0.1
b2=2.0
d1=0.4
d2=0.01

w0=[1,1,1]
tstart=0
tend=10000
dt=0.01
t=np.arange(tstart,tend+dt,dt)
w=odeint(Fw,w0,t,args=(a1,b1,a2,b2,d1,d2))

#it looks like the constant z they chose in the paper was ~9
z_const=9
z_arr=w[:,2]
z_const_ind=[]

#need to find the x values whenever z reaches z_const
#find indices where z is z_const
#because of precision issues, z won't ever be exactly z_const
#find index where values on either side are on either side of z_const

for i in range(1,len(z_arr)-1):
    if z_arr[i-1]<z_const and z_arr[i]<=z_const and z_arr[i+1]>z_const:
        z_const_ind.append(i)


x_arr=w[:,0]
x_arr_n=x_arr[z_const_ind]

y_arr=w[:,1]
y_arr_n=y_arr[z_const_ind]

plt.figure()
plt.scatter(x_arr_n,y_arr_n)
plt.xlabel('x(n)')
plt.ylabel('y(n)')
plt.show()

x_arr_n1=x_arr_n[1:]

plt.figure()
plt.scatter(x_arr_n[:len(x_arr_n)-1],x_arr_n1)
plt.xlabel('x(n)')
plt.ylabel('x(n+1)')
plt.show()


